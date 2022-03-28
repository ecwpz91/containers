FROM ubi8/s2i-base:1

# This image provides an Apache+PHP environment for running Drupal
# applications.

EXPOSE 8080
EXPOSE 8443

# Description
# This image provides an Apache 2.4 + PHP 7.4 environment for running Drupal applications.
# Exposed ports:
# * 8080 - alternative port for http

# https://www.drupal.org/node/3060/release
ENV DRUPAL_VERSION=9.3.9 \
    DRUPAL_MD5=09ff49df4ee07a1afc8339e5f22c2c14 \
    DRUPAL_VER_SHORT=93 \
    DRUPAL_VER_MAJOR=9 \
    DRUPAL_VER_MINOR=3 \
    PHP_VERSION=7.4 \
    PHP_VER_SHORT=74 \
    NAME=drupal

ENV SUMMARY="Platform for building and running Durpal $DRUPAL_VERSION applications" \
    DESCRIPTION="Durpal $DRUPAL_VERSION available as container is a base platform for \
                 building and running various Durpal $DRUPAL_VERSION applications and frameworks. \
                 Drupal is a free and open-source web content management system (CMS) written in PHP."

LABEL name="ecwpz91/s2i-${NAME}-${DRUPAL_VER_SHORT}" \
      summary="${SUMMARY}" \
      description="${DESCRIPTION}" \
      version="${DRUPAL_VER_MAJOR}" \
      release="${DRUPAL_VER_MINOR}" \
      maintainer="Michael Surbey <msurbey@redhat.com>" \
      io.k8s.description="${DESCRIPTION}" \
      io.k8s.display-name="Nginx with Durpal ${DRUPAL_VERSION}" \
      io.openshift.expose-services="8080:http" \
      io.openshift.tags="builder,${NAME},${NAME}${DRUPAL_VER_SHORT},${NAME}-${DRUPAL_VER_SHORT}" \
      io.openshift.s2i.scripts-url="image:///usr/libexec/s2i" \
      io.s2i.scripts-url="image:///usr/libexec/s2i" \
      run="docker run -d --name drupal -p 8080:8080 ${NAME}" \
      usage="s2i build <SOURCE-REPOSITORY> ${NAME} my-drupal-site" \
      com.redhat.component="${NAME}-${DRUPAL_VER_SHORT}-container" \
      com.redhat.license_terms="https://www.redhat.com/en/about/red-hat-end-user-license-agreements#UBI"

# Install Apache httpd and PHP
RUN yum -y module enable php:$PHP_VERSION && \
    INSTALL_PKGS="php php-mysqlnd php-pgsql php-bcmath \
                  php-gd php-intl php-json php-ldap php-mbstring php-pdo \
                  php-process php-soap php-opcache php-xml \
                  php-gmp php-pecl-apcu php-pecl-zip mod_ssl hostname" && \
    yum install -y --setopt=tsflags=nodocs $INSTALL_PKGS && \
    rpm -V $INSTALL_PKGS && \
    yum -y clean all --enablerepo='*'

ENV PHP_CONTAINER_SCRIPTS_PATH=/usr/share/container-scripts/php/ \
    APP_DATA=${APP_ROOT}/src \
    PHP_DEFAULT_INCLUDE_PATH=/usr/share/pear \
    PHP_SYSCONF_PATH=/etc \
    PHP_HTTPD_CONF_FILE=php.conf \
    HTTPD_CONFIGURATION_PATH=${APP_ROOT}/etc/conf.d \
    HTTPD_MAIN_CONF_PATH=/etc/httpd/conf \
    HTTPD_MAIN_CONF_D_PATH=/etc/httpd/conf.d \
    HTTPD_MODULES_CONF_D_PATH=/etc/httpd/conf.modules.d \
    HTTPD_VAR_RUN=/var/run/httpd \
    HTTPD_DATA_PATH=/var/www \
    HTTPD_DATA_ORIG_PATH=/var/www \
    HTTPD_VAR_PATH=/var

# Install Drupal
RUN curl -fSL "http://ftp.drupal.org/files/projects/drupal-${DRUPAL_VERSION}.tar.gz" -o drupal.tar.gz \
	&& echo "${DRUPAL_MD5} *drupal.tar.gz" | md5sum -c - \
    && mkdir -p /opt/rh/rh-drupal93 \
	&& tar -xz --strip-components=1 -f drupal.tar.gz -C /opt/rh/rh-drupal93 \
	&& rm -rf drupal.tar.gz \
    # Remove systemd boot targets - improves container init performance
    && (cd /lib/systemd/system/sysinit.target.wants \
    && for i in *; do [ $i = systemd-tmpfiles-setup.service ] || rm -vf $i; done) \
    && rm -rf /lib/systemd/system/multi-user.target.wants/*      \
            /etc/systemd/system/*.wants/*                      \
            /lib/systemd/system/local-fs.target.wants/*        \
            /lib/systemd/system/sockets.target.wants/*udev*    \
            /lib/systemd/system/sockets.target.wants/*initctl* \
            /lib/systemd/system/basic.target.wants/*           \
            /lib/systemd/system/anaconda.target.wants/*

# Copy the S2I scripts from the specific language image to $STI_SCRIPTS_PATH
COPY ./s2i/bin/ $STI_SCRIPTS_PATH

# Copy extra files to the image.
COPY ./root/ /

# Reset permissions of filesystem to default values
RUN /usr/libexec/container-setup && rpm-file-permissions

USER 1001

# Set the default CMD to print the usage of the language image
CMD $STI_SCRIPTS_PATH/usage
