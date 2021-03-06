# Dockerizing RHEL7: Dockerfile for building database images.
# Based on dbsys-base-7/base:1.1, installs MySQL 5.7 (GA).

FROM dbsys-base-7/base:1.1

MAINTAINER Michael Surbey <msurbey@redhat.com>

# Environment variables
ENV DBSYS_IMAGE_NAME="dbsys-base-7/mysql57" \
    DBSYS_IMAGE_VERSION="1.1" \
    DBSYS_IMAGE_RELEASE="9" \
    MYSQL_MAJOR="5.7" \
    MYSQL_VERSION="5.7.15-el7"

# Labels
LABEL Name="$DBSYS_IMAGE_NAME" \
      Version="$DBSYS_IMAGE_VERSION" \
      Release="$DBSYS_IMAGE_RELEASE" \
      Architecture="x86_64" \
      BZComponent="dbsys-base-7-mysql57-docker"

USER root

ADD mysql.repo /etc/yum.repos.d/

# Install required RPMs
RUN yum -y install --disablerepo \* --enablerepo=centos --enablerepo=mysql57 \
    mysql-server \
    && yum clean all \
    && rm -rf /var/cache/yum/* \
    && rm -rf /etc/yum.repos.d/centos.repo \
    && rm -rf /etc/yum.repos.d/mysql.repo

USER dbsys
