# The FROM instruction initializes a new build stage and sets the Base Image for subsequent instructions.
FROM docker://docker.io/fedora:latest

# The MAINTAINER instruction sets the Author field of the generated images.
MAINTAINER Mike Surbey <msurbey@redhat.com>

# The RUN instruction will execute any commands in a new layer on top of the current image and commit the results.
RUN dnf -y update; dnf -y clean all
RUN dnf -y install nginx --setopt install_weak_deps=false; dnf -y clean all
RUN echo "daemon off;" >> /etc/nginx/nginx.conf

# The COPY instruction copies new files or directories and adds them to the filesystem of the container at the destination path.
COPY index.html /usr/share/nginx/html/

# The EXPOSE instruction informs Docker that the container listens on the specified network ports at runtime.
EXPOSE 80

# The main purpose of a CMD is to provide defaults for an executing container.
CMD [ "/usr/sbin/nginx" ]
