# Dockerizing RHEL7: Dockerfile for building JBoss images.
# Based on rhel7.3-beta/rhel7.3, creates initial group & user account.

FROM registry.access.redhat.com/rhel7.3-beta/rhel7.3:latest

MAINTAINER Michael Surbey <msurbey@redhat.com>

# Environment variables
ENV JBOSS_IMAGE_NAME="jboss-base-7/base" \
    JBOSS_IMAGE_VERSION="1.2" \
    JBOSS_IMAGE_RELEASE="7" \
    HOME="/home/jboss"

# Labels
LABEL Name="$JBOSS_IMAGE_NAME" \
      Version="$JBOSS_IMAGE_VERSION" \
      Release="$JBOSS_IMAGE_RELEASE" \
      Architecture="x86_64" \
      BZComponent="jboss-base-7-base-docker"

USER root
# Create a user and group used to launch processes
# We use the ID 185 for the group as well as for the user.
# This ID is registered static ID for the JBoss EAP product
# on RHEL which makes it safe to use.
RUN groupadd -r jboss -g 185 && \
    useradd -u 185 -r -g jboss -m -d $HOME -s /sbin/nologin -c "JBoss user" jboss

USER jboss
# Set the working directory to jboss' user home directory
WORKDIR /home/jboss
