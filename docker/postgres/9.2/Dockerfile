# Dockerizing RHEL7: Dockerfile for building database images.
# Based on dbsys-base-7/postgresql92:1.1, installs PostgreSQL 9.2.

FROM  dbsys-base-7/postgresql92:1.1

MAINTAINER Michael Surbey <msurbey@redhat.com>

# Environment variables
ENV DBSYS_IMAGE_NAME="dbsys-postgres-9/postgres92" \
    DBSYS_IMAGE_VERSION="1.1" \
    DBSYS_IMAGE_RELEASE="4" \
    PGDATA="/var/lib/pgsql" \
    PGINST="/usr/pgsql"


# Labels
LABEL Name="$DBSYS_IMAGE_NAME" \
      Version="$DBSYS_IMAGE_VERSION" \
      Release="$DBSYS_IMAGE_RELEASE" \
      Architecture="x86_64" \
      BZComponent="dbsys-postgres-9-postgres92-docker"

EXPOSE 5432

COPY financials-psql.sql postgres-entrypoint /home/dbsys/

USER root

RUN groupadd -r postgres --gid=500 && useradd -r -g postgres --uid=500 postgres \
    && mkdir /docker-entrypoint-initdb.d \
    && mkdir -p /var/run/postgresql && chown -R postgres /var/run/postgresql \
    && ln -s /home/dbsys/financials-psql.sql /docker-entrypoint-initdb.d \
    && ln -s /home/dbsys/postgres-entrypoint /usr/local/bin \
    && rm -rf $PGDATA

VOLUME /var/lib/psql

USER postgres

ENTRYPOINT ["postgres-entrypoint"]

CMD ["postgres"]
