# This image provides a Ruby environment you can use to run your Ruby applications.
FROM ubi8/s2i-base:1

# Set the default port for applications built using this image
EXPOSE 8080

# Inform about software versions being used inside the builder
ENV JEKYLL_VERSION=3.5.0 \
    RUBY_MAJOR_VERSION=2 \
    RUBY_MINOR_VERSION=7 \
    NGINX_VERSION=1.20 \
    NGINX_SHORT_VER=120

ENV RUBY_VERSION="${RUBY_MAJOR_VERSION}.${RUBY_MINOR_VERSION}" \
    RUBY_SCL_NAME_VERSION="${RUBY_MAJOR_VERSION}${RUBY_MINOR_VERSION}"

ENV RUBY_SCL="ruby-${RUBY_SCL_NAME_VERSION}" \
    IMAGE_NAME="ecwpz91/jekyll-${JEKYLL_VERSION}" \
    SUMMARY="Platform for building and running Jekyll $JEKYLL_VERSION applications" \
    DESCRIPTION="Jekyll $JEKYLL_VERSION available as container is a base platform for \
building and running various Jekyll-based static sites."

ENV NGINX_CONFIGURATION_PATH=${APP_ROOT}/etc/nginx.d \
    NGINX_CONF_PATH=/etc/nginx/nginx.conf \
    NGINX_DEFAULT_CONF_PATH=${APP_ROOT}/etc/nginx.default.d \
    NGINX_CONTAINER_SCRIPTS_PATH=/usr/share/container-scripts/nginx \
    NGINX_APP_ROOT=${APP_ROOT} \
    NGINX_LOG_PATH=/var/log/nginx \
    NGINX_PERL_MODULE_PATH=${APP_ROOT}/etc/perl

# Labels used in OpenShift to describe the builder image
LABEL name="${IMAGE_NAME}" \
      summary="$SUMMARY" \
      description="$DESCRIPTION" \
      version="$RUBY_MAJOR_VERSION" \
      release="$RUBY_MINOR_VERSION" \
      maintainer="Michael Surbey <msurbey@redhat.com>" \
      io.k8s.description="$DESCRIPTION" \
      io.k8s.display-name="Jekyll ${JEKYLL_VERSION}" \
      io.openshift.expose-services="8080:http" \
      io.openshift.tags="builder,ruby,ruby${RUBY_SCL_NAME_VERSION},${RUBY_SCL},jekyll,static" \
      run="docker run -d --name jekyll -p 8080:8080 ${IMAGE_NAME}" \
      usage="s2i build <SOURCE-REPOSITORY> ${IMAGE_NAME} my-jekyll-site" \
      com.redhat.component="${RUBY_SCL}-container" \
      com.redhat.license_terms="https://www.redhat.com/en/about/red-hat-end-user-license-agreements#UBI"

# Install required Jekyll packages
RUN yum -y module enable ruby:$RUBY_VERSION && \
    INSTALL_PKGS=" \
    libffi-devel \
    ruby \
    ruby-devel \
    rubygem-rake \
    rubygem-bundler \
    redhat-rpm-config \
    " && \
    yum install -y --setopt=tsflags=nodocs ${INSTALL_PKGS} && \
    yum -y clean all --enablerepo='*' && \
    rpm -V ${INSTALL_PKGS}

# Install required Nginx packages
RUN yum -y module enable nginx:$NGINX_VERSION && \
    INSTALL_PKGS="nss_wrapper bind-utils gettext hostname nginx nginx-mod-stream nginx-mod-http-perl" && \
    yum install -y --setopt=tsflags=nodocs $INSTALL_PKGS && \
    rpm -V $INSTALL_PKGS && \
    yum -y clean all --enablerepo='*'

# Copy the S2I scripts from the specific language image to $STI_SCRIPTS_PATH
COPY ./s2i/bin/ $STI_SCRIPTS_PATH

# Copy extra files to the image.
COPY ./root/ /

# Install Jekyll and Bundler with RubyGems
RUN bash -c "gem install --no-document jekyll bundler"

# Create directories for nginx
# RUN mkdir -p ${APP_ROOT}/etc/nginx && \
#     mkdir -p ${APP_ROOT}/etc/nginx.include.d && \
#     mkdir -p ${APP_ROOT}/var/run/nginx && \
#     mkdir -p ${APP_ROOT}/var/log/nginx && \
#     mkdir -p ${APP_ROOT}/var/lib/nginx/tmp && \
#     chgrp -R 0 /var/opt/rh/rh-nginx18 && \
#     chmod -R g+rwX /var/opt/rh/rh-nginx18

# In order to drop the root user, we have to make some directories world
# writable as OpenShift default security model is to run the container under
# random UID.
RUN sed -i -f ${NGINX_APP_ROOT}/nginxconf-fed.sed ${NGINX_CONF_PATH} && \
    chmod a+rwx ${NGINX_CONF_PATH} && \
    mkdir -p ${NGINX_APP_ROOT}/etc/nginx.d/ && \
    mkdir -p ${NGINX_APP_ROOT}/etc/nginx.default.d/ && \
    mkdir -p ${NGINX_APP_ROOT}/src/nginx-start/ && \
    mkdir -p ${NGINX_CONTAINER_SCRIPTS_PATH}/nginx-start && \
    mkdir -p ${NGINX_LOG_PATH} && \
    mkdir -p ${NGINX_PERL_MODULE_PATH} && \
    chmod -R a+rwx ${NGINX_APP_ROOT}/etc && \
    chmod -R a+rwx /var/lib/nginx && \
    chmod -R a+rwx ${NGINX_CONTAINER_SCRIPTS_PATH}/nginx-start && \
    chown -R 1001:0 ${NGINX_APP_ROOT} && \
    chown -R 1001:0 /var/lib/nginx && \
    chown -R 1001:0 ${NGINX_CONTAINER_SCRIPTS_PATH}/nginx-start && \
    # FIXME: Not sure if this is safe to do, just a hack to make the image work
    chmod -R a+rwx /var/run && \
    chown -R 1001:0 /var/run && \
    rpm-file-permissions

# Drop the root user and make the content of /opt/app-root owned by user 1001
RUN chown -R 1001:0 ${APP_ROOT} && chmod -R ug+rwx ${APP_ROOT} && \
    rpm-file-permissions

USER 1001

# Not using VOLUME statement since it's not working in OpenShift Online:
# https://github.com/sclorg/httpd-container/issues/30
# VOLUME ["/usr/share/nginx/html"]
# VOLUME ["/var/log/nginx/"]

# Set the default CMD to print the usage of the language image
CMD $STI_SCRIPTS_PATH/usage
