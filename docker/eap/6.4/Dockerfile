# Dockerizing JBoss Enterprise Application Server (EAP): Dockerfile for
# building JavaEE web applications.
# Based on jboss-base-7/jdk8:1.2, installs JBoss EAP 6.4.9.GA.

FROM jboss-base-7/jdk8:1.2

# Environment variables
ENV JBOSS_IMAGE_NAME="jboss-eap-6/eap64" \
    JBOSS_IMAGE_VERSION="1.2" \
    JBOSS_IMAGE_RELEASE="1" \
    LAUNCH_JBOSS_IN_BACKGROUND="true" \
    JBOSS_PRODUCT="eap" \
    JBOSS_EAP_VERSION="6.4.9.GA" \
    JBOSS_HOME="/opt/eap"

# Labels
LABEL Name="$JBOSS_IMAGE_NAME" \
      Version="$JBOSS_IMAGE_VERSION" \
      Release="$JBOSS_IMAGE_RELEASE" \
      Architecture="x86_64" \
      BZComponent="jboss-eap-6-eap64-docker" \
      org.jboss.deployments-dir="/opt/eap/standalone/deployments" \
      com.redhat.deployments-dir="/opt/eap/standalone/deployments" \
      com.redhat.dev-mode="DEBUG:true" \
      com.redhat.dev-mode.port="DEBUG_PORT:8787"

EXPOSE 8080 9990 8787

COPY jboss-eap-6.4.9-full-build.tar.gz install_eap64 /tmp/

USER root

RUN /tmp/install_eap64

USER jboss

# Boot EAP in standalone mode by default
# When using CMD environment variables are not expanded,
# so we need to specify the $JBOSS_HOME path
CMD ["/opt/eap/bin/standalone.sh", "-b", "0.0.0.0", "-bmanagement", "0.0.0.0"]
