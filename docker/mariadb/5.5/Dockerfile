# Dockerizing RHEL7: Dockerfile for building database images.
# Based on dbsys-base-7/base:1.1, installs MariaDB 5.5 (stable).

FROM dbsys-base-7/base:1.1

MAINTAINER Michael Surbey <msurbey@redhat.com>

# Environment variables
ENV DBSYS_IMAGE_NAME="dbsys-base-7/mariadb55" \
    DBSYS_IMAGE_VERSION="1.1" \
    DBSYS_IMAGE_RELEASE="5" \
    MARIADB_MAJOR="5.5" \
    MARIADB_VERSION="5.5.44-el7"

# Labels
LABEL Name="$DBSYS_IMAGE_NAME" \
      Version="$DBSYS_IMAGE_VERSION" \
      Release="$DBSYS_IMAGE_RELEASE" \
      Architecture="x86_64" \
      BZComponent="dbsys-base-7-mariadb55-docker"

USER root

# Install required RPMs
RUN yum -y install --disablerepo \* --enablerepo=centos mariadb-server \
    && yum clean all \
    && rm -rf /var/cache/yum/* \
    && rm -rf /var/lib/{yum}/ \
    && rm -rf /etc/yum.repos.d/centos.repo

USER dbsys
