FROM centos/mongodb-tarball-centos7

ENV MONGODB_VERSION=3.4 \
    CONTAINER_SCRIPTS_PATH="/usr/share/container-scripts/mongodb"

LABEL io.k8s.description="MongoDB is a scalable, high-performance, open source NoSQL database." \
      io.k8s.display-name="MongoDB $MONGODB_VERSION" \
      io.openshift.expose-services="27017:mongodb" \
      io.openshift.tags="database,mongodb" \
      Authors="John Osborne <johnfosborneiii@gmail.com>,Michael Surbey <msurbey@redhat.com>"

RUN yum -y install --setopt=tsflags=nodocs \
                   cyrus-sasl              \
                   cyrus-sasl-plain        \
                   cyrus-sasl-gssapi       \
                   krb5-libs               \
                   libcurl                 \
                   lm_sensors-libs         \
                   net-snmp-agent-libs     \
                   net-snmp                \
                   openssl                 \
                   rpm-libs                \
                   tcp_wrappers-libs    && \
    yum clean all

ADD root /

RUN curl -L 'https://downloads.mongodb.com/linux/mongodb-linux-x86_64-enterprise-rhel70-3.4.2.tgz' | tar -xzf - -C $APP_HOME --strip 1 && \
    touch /etc/mongod.conf && \
    /usr/libexec/fix-permissions /etc/mongod.conf $CONTAINER_SCRIPTS_PATH/mongodb.conf.template $HOME && \    
    ln -s $APP_HOME/bin/* /usr/bin

EXPOSE 27017

USER mongodb

CMD ["run-mongod"]
