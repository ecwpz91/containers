FROM gcr.io/kuar-demo/kuard-amd64:1
MAINTAINER Mike Surbey <msurbey@redhat.com>
EXPOSE 8080
ENV NAME="Mike"
# LABEL io.k8s.description="Platform for building xyz" \
#      io.k8s.display-name="builder x.y.z" \
#      io.openshift.expose-services="8080:http" \
#      io.openshift.tags="builder,x.y.z,etc."
RUN echo "Hello kuard!" > /tmp/newfile
RUN echo "Hello kuard!" >> /tmp/newfile
