FROM docker.elastic.co/elasticsearch/elasticsearc:5.5.0

USER 0

# Location of the STI scripts inside the image.
LABEL io.openshift.s2i.scripts-url=image:///usr/libexec/s2i \
# DEPRECATED: This label will be kept here for backward compatibility.
      io.s2i.scripts-url=image:///usr/libexec/s2i

# DEPRECATED: Use above LABEL instead, because this will be removed in future versions.
ENV STI_SCRIPTS_URL=image:///usr/libexec/s2i \
# Path to be used in other layers to place s2i scripts into
  STI_SCRIPTS_PATH=/usr/libexec/s2i \
# The $HOME is not set by default, but some applications needs this variable
  HOME=/opt/app-root/src \
  PATH=/opt/app-root/src/bin:/opt/app-root/bin:$PATH

# TODO: Set installation sources
ENV CONTAINER="docker" \
  LANG="en_US.UTF-8" \
  TERM="xterm" \
  HOME="/usr/share/elasticsearch" \
  APP_MAJOR="5" \
  APP_MINOR="5" \
  APP_PATCH="0" \
  APP_OPT="rh" \
  APP_SRC="" \
  NSS_SRC="https://dl.fedoraproject.org/pub/epel/7/x86_64/n" \
  NSS_RPM="nss_wrapper-1.1.3-1.el7.x86_64.rpm"

ENV JAVA_VER=1.8.0 \
  ES_VER=5.5.0 \
  ES_CLOUD_K8S_VER=5.0.0 \
  OSE_ES_VER=2.4.4.9 \
  ES_CONF=/usr/share/java/elasticsearch/config \
  INSTANCE_RAM=512G \
  NODE_QUORUM=1 \
  RECOVER_AFTER_NODES=1 \
  RECOVER_EXPECTED_NODES=1 \
  RECOVER_AFTER_TIME=5m \
  PLUGIN_LOGLEVEL=INFO \
  ES_JAVA_OPTS="-Dmapper.allow_dots_in_name=true"

# TODO: Set runtime summary and desc
ENV SUMMARY="" \
  DESCRIPTION="Elasticsearch container for flexible storage" \
  APP_HOME="/opt/$APP_OPT/elastic-$APP_MINOR.$APP_PATCH" \
  APP_VERSION="$APP_MAJOR.$APP_MINOR"

# Incantations to enable Software Collections
ENV ENABLED_COLLECTIONS="$APP_OPT-elastic$APP_MAJOR$APP_MINOR" \
  BASH_ENV="/opt/app-root/etc/scl_enable" \
  ENV="/opt/app-root/etc/scl_enable" \
  PROMPT_COMMAND=". /opt/app-root/etc/scl_enable" \
  APP_ARCHIVE="v$APP_MAJOR.$APP_MINOR.$APP_PATCH.tar.gz"

# TODO: Set exposed runtime services
LABEL summary="$SUMMARY" \
  io.k8s.description="$DESCRIPTION" \
  io.k8s.display-name="Elastic $APP_VERSION" \
  io.openshift.expose-services="" \
  io.openshift.tags="elastic" \
  com.redhat.component="$ENABLED_COLLECTIONS-docker" \
  name="centos/elastic-55-centos7" \
  version="1.5.0" \
  release="$APP_PATCH" \
  architecture="x86_64"
  maintainer="SoftwareCollections.org <sclorg@redhat.com>"

# This is the list of basic dependencies that all language Docker image can
# consume.
# Also setup the 'openshift' user that is used for the build execution and for the
# application runtime execution.
# TODO: Use better UID and GID values
RUN rpmkeys --import file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7 && \
  INSTALL_PKGS="bsdtar \
  findutils \
  gettext \
  scl-utils \
  tar \
  unzip \
  yum-utils" && \
  mkdir -p ${HOME}/.pki/nssdb && \
  chown -R 1001:0 ${HOME}/.pki && \
  yum install -y --setopt=tsflags=nodocs $INSTALL_PKGS && \
  rpm -V $INSTALL_PKGS && \
  yum clean all -y && \
  useradd -u 1001 -r -g 0 -d ${HOME} -s /sbin/nologin \
      -c "Default Application User" default && \
  chown -R 1001:0 /opt/app-root

WORKDIR /usr/share/elasticsearch

# TODO: Install required packages
RUN yum install -y centos-release-scl \
&& yum-config-manager --enable centos-sclo-rh-testing \
&& INSTALL_PKGS="" \
&& yum install -y --setopt=tsflags=nodocs $INSTALL_PKGS $NSS_SRC/$NSS_RPM --nogpgcheck \
&& rpm -V $INSTALL_PKGS \
&& mkdir -p $APP_HOME \
&& curl -L $APP_SRC/$APP_ARCHIVE \
| tar -xzf - -C $APP_HOME --strip 1 \
&& yum -y clean all

# Remove systemd boot targets - improves container init performance
RUN \(cd /lib/systemd/system/sysinit.target.wants \
&& for i in *; do [ $i = systemd-tmpfiles-setup.service ] || rm -vf $i; done\) \
&& rm -rf /lib/systemd/system/multi-user.target.wants/* \
  /etc/systemd/system/*.wants/* \
  /lib/systemd/system/local-fs.target.wants/* \
  /lib/systemd/system/sockets.target.wants/*udev* \
  /lib/systemd/system/sockets.target.wants/*initctl* \
  /lib/systemd/system/basic.target.wants/* \
  /lib/systemd/system/anaconda.target.wants/*

# Copy the S2I scripts from the specific language image to $STI_SCRIPTS_PATH
COPY ./s2i/bin/ $STI_SCRIPTS_PATH

# Copy extra files to the image.
COPY ./root/ /

RUN fix-permissions /opt/app-root

USER 1001

ENTRYPOINT ["container-entrypoint"]
CMD ["/usr/libexec/s2i/usage"]
