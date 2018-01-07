# Dockerizing RHEL7: Dockerfile for building database images.
# Based on dbsys-base-7/mysql57:1.1, installs MySQL 5.7 (GA).

FROM dbsys-base-7/mysql57:1.1

MAINTAINER Michael Surbey <msurbey@redhat.com>

# Environment variables
ENV DBSYS_IMAGE_NAME="dbsys-mysql-5/mysql57" \
    DBSYS_IMAGE_VERSION="1.1" \
    DBSYS_IMAGE_RELEASE="8" \
    MYSQL_USER="shadowman" \
    MYSQL_PASSWORD="r3dh4t1!" \
    MYSQL_DATABASE="test" \
    MYSQL_ROOT_PASSWORD="my-secret-pw" \
    MYSQL_HOME="/var/lib/mysql"

# Labels
LABEL Name="$DBSYS_IMAGE_NAME" \
      Version="$DBSYS_IMAGE_VERSION" \
      Release="$DBSYS_IMAGE_RELEASE" \
      Architecture="x86_64" \
      BZComponent="dbsys-mysql-5-mysql57-docker"

EXPOSE 3306

COPY mysqld-entrypoint /home/dbsys/

USER root

RUN chown -R mysql:mysql /var/lib/mysql \
    && ln -s /home/dbsys/mysqld-entrypoint /usr/local/bin \
    && ln -s /usr/local/bin/mysqld-entrypoint /mysqld-entrypoint # backwards compat

VOLUME /var/lib/mysql

USER mysql

ENTRYPOINT ["mysqld-entrypoint"]

CMD ["mysqld"]
