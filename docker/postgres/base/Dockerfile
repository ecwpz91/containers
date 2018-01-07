# Dockerizing RHEL7: Dockerfile for building database images.
# Based on dbsys-base-7/base:1.1, installs PostgreSQL 9.2 (also supplies
# package rh-postgresql95 and rh-postgresql94 via SCL).

FROM dbsys-base-7/base:1.1

MAINTAINER Michael Surbey <msurbey@redhat.com>

# Environment variables
ENV DBSYS_IMAGE_NAME="dbsys-base-7/postgresql92" \
    DBSYS_IMAGE_VERSION="1.1" \
    DBSYS_IMAGE_RELEASE="2" \
    POSTGRESQL_MAJOR="9.2" \
    POSTGRESQL_VERSION="9.2.13-el7"

# Labels
LABEL Name="$DBSYS_IMAGE_NAME" \
      Version="$DBSYS_IMAGE_VERSION" \
      Release="$DBSYS_IMAGE_RELEASE" \
      Architecture="x86_64" \
      BZComponent="dbsys-base-7-postgresql92-docker"

USER root

# Install required RPMs
RUN yum -y install --disablerepo \* --enablerepo=centos --skip-broken postgresql-server \
    && yum clean all \
    && rm -rf /var/cache/yum/* \
    && rm -rf /etc/yum.repos.d/centos.repo

USER dbsys
