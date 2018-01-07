# Dockerizing MongoDB: MongoDB Ops Manager Image.

FROM mongo-34:1.1

# Environment variables
ENV IMAGE_NAME="mongo-34-db-mms" \
    IMAGE_VERSION="1.1" \
    IMAGE_RELEASE="3"

# Build labels
LABEL Name="$IMAGE_NAME" \
      Version="$IMAGE_VERSION" \
      Release="$IMAGE_RELEASE" \
      Architecture="x86_64" \
      BZComponent="mongodb-mms-docker" \
      Authors="John Osborne <johnfosborneiii@gmail.com>, Michael Surbey <msurbey@redhat.com>" \
      io.k8s.description="Ops Manager is a package for managing MongoDB deployments." \
      io.k8s.display-name="MongoDB Ops Manager $MONGODB_VERSION" \
      io.openshift.expose-services="443:mms" \
      io.openshift.tags="mms,ops,management"

RUN yum -y install --setopt=tsflags=nodocs \
                   httpd                && \
    yum clean all

ADD root /

# Install archive (.tgz)
RUN mkdir -p $APP_HOME && \
    curl -L 'https://downloads.mongodb.com/on-prem-mms/tar/mongodb-mms-3.4.3.402-1.x86_64.tar.gz' | tar -xzf - -C $HOME --strip 1 && \
    # Create configuration file
    touch /etc/mongodb-mms/mms.conf && \
    # Change owner and group permission bits
    chown mongod:0 /etc/mongodb-mms/mms.conf

EXPOSE 8080 8443

USER mongo

CMD ["run-mongo"]
