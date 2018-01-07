# Dockerizing RHEL7: Dockerfile for building JBoss images.
# Based on jboss-base-7/base:1.2, installs OpenJDK (v1.8).

FROM jboss-base-7/base:1.2

MAINTAINER Michael Surbey <msurbey@redhat.com>

# Environment variables
ENV JBOSS_IMAGE_NAME="jboss-base-7/jdk8" \
    JBOSS_IMAGE_VERSION="1.2" \
    JBOSS_IMAGE_RELEASE="6" \
    JAVA_HOME="/usr/lib/jvm/java-1.8.0" \
    JAVA_VENDOR="openjdk" \
    JAVA_VERSION="1.8.0" \
    JAVA_TOOL_OPTIONS="-Duser.home=/home/jboss -Duser.name=jboss"

# Labels
LABEL Name="$JBOSS_IMAGE_NAME" \
      Version="$JBOSS_IMAGE_VERSION" \
      Release="$JBOSS_IMAGE_RELEASE" \
      Architecture="x86_64" \
      BZComponent="jboss-base-7-jdk8-docker"

USER root

# Install required RPMs
RUN yum -y install --disablerepo \* --enablerepo=centos java-1.8.0-openjdk-devel \
    && yum clean all \
    && rm -rf /var/cache/yum/* \
    && rm -rf /var/lib/{yum}/ \
    && rm -rf /etc/yum.repos.d/centos.repo

USER jboss
