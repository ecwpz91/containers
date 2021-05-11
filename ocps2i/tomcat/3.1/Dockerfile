FROM registry.redhat.io/jboss-webserver-3/webserver31-tomcat8-openshift:latest

ENV JBOSS_IMAGE_NAME="jboss-webserver-3/webserver31-tomcat8-openshift" \
    JBOSS_IMAGE_VERSION="1.4" \
    STI_BUILDER="jee"

LABEL com.redhat.component="jboss-webserver-3-webserver31-tomcat8-openshift-container"  \
      description="Red Hat JBoss Web Server 3.1 - Tomcat 8 OpenShift container image"  \
      io.cekit.version="3.8.0"  \
      io.k8s.description="Platform for building and running web applications on JBoss Web Server 3.1 - Tomcat v8"  \
      io.k8s.display-name="JBoss Web Server 3.1"  \
      io.openshift.expose-services="8080:http"  \
      io.openshift.s2i.scripts-url="image:///usr/local/s2i"  \
      io.openshift.tags="builder,java,tomcat8"  \
      maintainer="Michael Surbey <msurbey@redhat.com>" \
      name="ecwpz91/webserver31-tomcat8-openshift" \
      summary="Red Hat JBoss Web Server 3.1 - Tomcat 8 OpenShift container image"  \
      version="1.4" 

USER root

COPY root /

RUN /usr/libexec/fix-permissions $JWS_HOME/lib/mssql-jdbc-8.2.2.jre8.jar $JWS_HOME/conf/server.xml $JWS_HOME/conf/context.xml

USER 185

WORKDIR /home/jboss

CMD ["/opt/webserver/bin/launch.sh"]