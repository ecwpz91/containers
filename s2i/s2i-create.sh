#!/bin/bash

function s2i-create() {
 usage() {
cat <<EOF
OpenShift s2i create Wrapper Script

Usage:
  s2i-create <imageName> <destination>
EOF

  exit 1;
 }

 S2INAME=$1
 S2IDEST=$2; shift 2 || usage

 # base image name
 IMGBASE=$(echo $S2INAME | sed 's/\([a-z]*\)-[0-9].*/\1/')

 # base image version
 TEMPVER=$(echo $S2INAME | sed 's/.*\([0-9][0-9]\).*/\1/')
 VERSION=$(echo ${TEMPVER:0:1}.${TEMPVER:0:1})

 # base image home
 IMGHOME=$S2IDEST/$VERSION

 # base image root
 IMGROOT=$IMGHOME/root

 # base image add-on
 APPROOT=/opt/app-root

 # app etc directory
 ETCPATH=$APPROOT/etc

 # app src directory
 SRCPATH=$APPROOT/src

 # s2i scripts home
 S2IHOME=$IMGHOME/s2i

 # s2i scripts path
 S2IPATH=$S2IHOME/bin

 # s2i test scripts
 S2ICDIR=$VERSION/test/test-app

 # sclorg use params
 DISTRO=$(cat /etc/*-release | grep ^ID= | sed 's/ID=\([a-z]*\).*/\1/')
 NAMESPACE=centos
 [[ $DISTRO =~ rhel* ]] && NAMESPACE=rhscl

 # sclorg build help
 [ ! -f $S2IDEST/.gitmodules ] && \
cat <<EOF > $S2IDEST/.gitmodules
[submodule "common"]
	path = common
	url = https://github.com/sclorg/container-common-scripts.git
EOF

 # git .ignore file
 [ ! -f $S2IDEST/.gitignore ] && \
cat <<EOF > $S2IDEST/.gitignore
# help.1 complied from README
*/root/help.1

# common module temp version
Dockerfile.version

# any temporary file/folder
*tmp*
EOF

 # project Makefile
 [ ! -f $S2IDEST/Makefile ] && \
cat <<EOF > $S2IDEST/Makefile
# Variables are documented in hack/build.sh.
BASE_S2INAME = $IMGBASE
VERSIONS = $VERSION
OPENSHIFT_NAMESPACES = 2.4

# HACK:  Ensure that 'git pull' for old clones doesn't cause confusion.
# New clones should use '--recursive'.
.PHONY: \$(shell test -f common/common.mk || echo >&2 'Please do "git submodule update --init" first.')

include common/common.mk
EOF

 # create s2i scripts
 [ ! -d $IMGHOME ] && s2i create $S2INAME $IMGHOME

 # patch folder name
 [ -d $IMGHOME/.s2i ] && mv $IMGHOME/.s2i $S2IHOME

 # s2i usage header
 S2IHEAD="${S2INAME^^} S2I IMAGE"

 # character length
 CHARLEN=${#S2IHEAD}

 # starry eyed surprise
 function starry() {
  for ((i=0; i<$CHARLEN; i++)); do
   echo -n "*"
  done
 }

 # create s2i usage
read -r -d '' VAR <<EOM
#!/bin/bash -e

cat <<EOF
$(starry)
$S2IHEAD
$(starry)

To use it, install the S2I tool via https://github.com/openshift/source-to-image

# Build new base image
s2i build git://<source> $NAMESPACE/$S2INAME --context-dir=$S2ICDIR

# Run a new container
docker run -d $NAMESPACE/$S2INAME /bin/bash -c 'while true; do sleep 1000; done'
EOF
EOM

 # overwrite s2i usage
cat <<EOF > $S2IPATH/usage
$VAR
EOF

 # make executable
 chmod +x $S2IPATH/*

 [ -f $IMGHOME/Makefile ] && rm -f $IMGHOME/Makefile

cat <<EOF > $IMGHOME/Dockerfile
FROM centos/s2i-base-centos7

# TODO: Set installation sources
ENV CONTAINER="docker" \\
  LANG="en_US.UTF-8" \\
  TERM="xterm" \\
  HOME="$SRCPATH" \\
  APP_MAJOR="${TEMPVER:0:1}" \\
  APP_MINOR="${TEMPVER:0:1}" \\
  APP_PATCH="" \\
  APP_OPT="rh" \\
  APP_SRC="" \\
  NSS_SRC="https://dl.fedoraproject.org/pub/epel/7/x86_64/n" \\
  NSS_RPM="nss_wrapper-1.1.3-1.el7.x86_64.rpm"

# TODO: Set runtime summary and desc
ENV SUMMARY="" \\
  DESCRIPTION="" \\
  APP_HOME="/opt/\$APP_OPT/$IMGBASE-\$APP_MINOR.\$APP_PATCH" \\
  APP_VERSION="\$APP_MAJOR.\$APP_MINOR"

# Incantations to enable Software Collections
ENV ENABLED_COLLECTIONS="\$APP_OPT-$IMGBASE\$APP_MAJOR\$APP_MINOR" \\
  APP_ARCHIVE="v\$APP_MAJOR.\$APP_MINOR.\$APP_PATCH.tar.gz"

# TODO: Set exposed runtime services
LABEL summary="\$SUMMARY" \\
  io.k8s.description="\$DESCRIPTION" \\
  io.k8s.display-name="${IMGBASE^} \$APP_VERSION" \\
  io.openshift.expose-services="" \\
  io.openshift.tags="$IMGBASE" \\
  com.redhat.component="\$ENABLED_COLLECTIONS-docker" \\
  name="$NAMESPACE/$S2INAME" \\
  version="1.5.0" \\
  release="\$APP_PATCH" \\
  architecture="x86_64"
  maintainer="SoftwareCollections.org <sclorg@redhat.com>"

# TODO: Install required packages
RUN yum install -y centos-release-scl \\
&& yum-config-manager --enable centos-sclo-rh-testing \\
&& INSTALL_PKGS="" \\
&& yum install -y --setopt=tsflags=nodocs \$INSTALL_PKGS \$NSS_SRC/\$NSS_RPM --nogpgcheck \\
&& rpm -V \$INSTALL_PKGS \\
&& mkdir -p \$APP_HOME \\
&& curl -L \$APP_SRC/\$APP_ARCHIVE \\
| tar -xzf - -C \$APP_HOME --strip 1 \\
&& yum -y clean all

# Remove systemd boot targets - improves container init performance
RUN \(cd /lib/systemd/system/sysinit.target.wants \\
&& for i in *; do [ \$i = systemd-tmpfiles-setup.service ] || rm -vf \$i; done\) \\
&& rm -rf /lib/systemd/system/multi-user.target.wants/* \\
  /etc/systemd/system/*.wants/* \\
  /lib/systemd/system/local-fs.target.wants/* \\
  /lib/systemd/system/sockets.target.wants/*udev* \\
  /lib/systemd/system/sockets.target.wants/*initctl* \\
  /lib/systemd/system/basic.target.wants/* \\
  /lib/systemd/system/anaconda.target.wants/*

# Copy the S2I scripts from the specific language image to \$STI_SCRIPTS_PATH
COPY ./s2i/bin/ \$STI_SCRIPTS_PATH

# Copy extra files to the image.
COPY ./root/ /

RUN fix-permissions $APPROOT

USER 1001

# Set the default CMD to print the usage of the language image
CMD ["/usr/libexec/s2i/usage"]
EOF

 mkdir -p $IMGROOT/$ETCPATH
 mkdir -p $IMGROOT/$SRCPATH

cat <<EOF > $IMGROOT/$ETCPATH/generate_container_user
# Set current user in nss_wrapper
USER_ID=$(id -u)
GROUP_ID=$(id -g)

if [ x"$USER_ID" != x"0" -a x"$USER_ID" != x"1001" ]; then
  NSS_WRAPPER_PASSWD=/opt/app-root/etc/passwd
  NSS_WRAPPER_GROUP=/etc/group

  cat /etc/passwd | sed -e 's/^default:/builder:/' > $NSS_WRAPPER_PASSWD

  echo "default:x:${USER_ID}:${GROUP_ID}:Default Application User:${HOME}:/sbin/nologin" >> $NSS_WRAPPER_PASSWD

  export NSS_WRAPPER_PASSWD
  export NSS_WRAPPER_GROUP

  LD_PRELOAD=libnss_wrapper.so
  export LD_PRELOAD
fi
EOF

cat <<EOF > $IMGROOT/$ETCPATH/scl_enable
#!/bin/bash

# IMPORTANT: Do not add more content to this file unless you know what you are
#            doing. This file is sourced everytime the shell session is opened.
# This will make scl collection binaries work out of box.
unset BASH_ENV PROMPT_COMMAND ENV

# Make scl collection binaries work out of box.
# source scl_source enable rh-$IMGBASE$TEMPVER
EOF

cat <<EOF > $IMGROOT/$SRCPATH/README.md
${IMGBASE^} Docker image
====================

This repository contains ${IMGBASE^} Dockerfiles for general use and with OpenShift.

Environment variables
---------------------------------

The image recognizes the following default values that you can set during by
passing \`-e VAR=VALUE\` to the Docker \`run\` command.

|    Name                   |    Description                   |    Value |
| :------------------------ | ---------------------------------| ---------|
|                           |                                  |          |

Usage
---------------------------------

For this, we will assume that you are using the \`$S2INAME\` image.
EOF

 [ -f $IMGHOME/README.md ] && ln -s "$IMGROOT/$SRCPATH/README.md" "$IMGHOME/README.md"

 [[ $NAMESPACE == "centos" ]] && \
cat <<EOF > $IMGHOME/cccp.yml
job-id: $S2INAME
EOF
}
