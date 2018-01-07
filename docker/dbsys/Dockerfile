# Dockerizing RHEL7: Dockerfile for building Database images.
# Based on rhel7.3-beta/rhel7.3, creates initial group & user account.

FROM registry.access.redhat.com/rhel7.3-beta/rhel7.3:latest

MAINTAINER Michael Surbey <msurbey@redhat.com>

# Environment variables
ENV DBSYS_IMAGE_NAME="dbsys-base-7/base" \
    DBSYS_IMAGE_VERSION="1.1" \
    DBSYS_IMAGE_RELEASE="1" \
    HOME="/home/dbsys"

# Labels
LABEL BZComponent="dbsys-base-7-docker" \
      Name="$DBSYS_IMAGE_NAME" \
      Version="$DBSYS_IMAGE_VERSION" \
      Release="$DBSYS_IMAGE_RELEASE" \
      Architecture="x86_64"

USER root

ADD centos.repo /etc/yum.repos.d/

# Create a user and group used to launch processes
# We use the ID 27 for the group as well as for the user.
# This ID is registered static ID for the dbsys product
# on RHEL which makes it safe to use.
RUN groupadd -r dbsys -g 27 && \
    useradd -u 27 -r -g dbsys -m -d $HOME -s /sbin/nologin -c "Database user" dbsys

USER dbsys

# Set the working directory to 'dbsys' user home directory
WORKDIR /home/dbsys
