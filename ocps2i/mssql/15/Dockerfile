FROM registry.access.redhat.com/ubi8:latest

ENV LANG="en_US.UTF-8" \
    TERM="xterm" \
    MAJOR="15" \
    MINOR="0" \
    PATCH="4123.1" \
    SUMMARY="Microsoft SQL Server 2019" \
    DESCRIPTION="Microsoft SQL Server 2019 (15.x) introduces Big Data Clusters for SQL Server. \
It also provides additional capability and improvements for the SQL Server database \ 
engine, SQL Server Analysis Services, SQL Server Machine Learning Services, SQL Server \
on Linux, and SQL Server Master Data Services." \
    HOME="/var/opt/mssql" \
    CONTAINER_SCRIPTS_PATH="/usr/share/container-scripts/mssql" \
    BASH_ENV="\${CONTAINER_SCRIPTS_PATH}/scl_enable" \
    ENV="\${CONTAINER_SCRIPTS_PATH}/scl_enable" \
    PROMPT_COMMAND=". \${CONTAINER_SCRIPTS_PATH}/scl_enable"

LABEL name="ecwpz91/mssql-2019-ubi8" \
      summary="$SUMMARY" \
      description="$DESCRIPTION" \
      version="$MAJOR" \
      release="$MINOR" \
      maintainer="Michael Surbey <msurbey@redhat.com>" \
      io.k8s.description="$DESCRIPTION" \
      io.k8s.display-name="Microsoft SQL Server 2019" \
      io.openshift.expose-services="1433:tcp" \
      io.openshift.tags="database,mssql" \
      run="docker run -d --name mssql -e ACCEPT_EULA=Y -e SA_PASSWORD=yourStrong@Password -p 1433:1433 ecwpz91/mssql-2019-ubi8" \
      com.redhat.license_terms="https://www.redhat.com/en/about/red-hat-end-user-license-agreements#rhel" \
      url="https://www.microsoft.com/en-us/sql-server/" \
      maintainer="ecwpz91 <ecwpz91@users.noreply.github.com>"

EXPOSE 1433

COPY root /

ENTRYPOINT ["container-entrypoint"]

RUN yum -y localinstall /tmp/*.rpm \
&& ACCEPT_EULA=Y yum -y install --setopt=tsflags=nodocs mssql-server mssql-tools unixODBC-devel nss_wrapper hostname \
&& yum clean all \
# Remove systemd boot targets - improves container init performance
&& (cd /lib/systemd/system/sysinit.target.wants \
&& for i in *; do [ $i = systemd-tmpfiles-setup.service ] || rm -vf $i; done) \
&& rm -rf /lib/systemd/system/multi-user.target.wants/*      \
          /etc/systemd/system/*.wants/*                      \
          /lib/systemd/system/local-fs.target.wants/*        \
          /lib/systemd/system/sockets.target.wants/*udev*    \
          /lib/systemd/system/sockets.target.wants/*initctl* \
          /lib/systemd/system/basic.target.wants/*           \
          /lib/systemd/system/anaconda.target.wants/*        \
          /tmp/*.rpm

# Create files and directory locations
RUN mkdir -p $HOME/data \
&& touch /tmp/passwd \
# Set owner 'mssql:0' and 'g+rw(x)' permission - to avoid problems running container with arbitrary UID
&& /usr/libexec/fix-permissions $CONTAINER_SCRIPTS_PATH/mssql.conf.template /tmp/passwd $HOME

CMD ["run-mysql"]

VOLUME ["/var/opt/mssql/data"]

USER mssql
