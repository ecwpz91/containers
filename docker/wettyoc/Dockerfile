FROM docker.io/krishnasrinivas/wetty

MAINTAINER Mike Surbey <msurbey@redhat.com>

EXPOSE 3000

ENV HOME="/home/term" \
    APP_URIS="https://mirror.openshift.com/pub/openshift-v3/clients/3.7.42/linux/oc.tar.gz" \
    APP_ROOT="/app"

# Install OpenShift command line tool
# RUN curl -L '' \
# | tar -xvzf - -C "$HOME/.local/bin" &>/dev/null

RUN  apt-get install -y openssh-server \
&& mkdir -p ${HOME}/.ssh \
&& touch ${HOME}/.ssh/authorized_keys

COPY root /

RUN chmod g=u /etc/passwd \
&& /usr/libexec/fix-permissions ${HOME} \
                                 ${APP_ROOT}

USER term
WORKDIR /home/term

ENTRYPOINT [ "/usr/libexec/uid_entrypoint" ]

CMD ["node", "/app/app.js", "-p", "3000"]
