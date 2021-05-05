Microsoft SQL Server 2019 Docker image
====================

This repository contains Microsoft SQL Server 2019 Dockerfiles for general use and with OpenShift.

Environment variables
---------------------------------

The image recognizes the following default values that you can set during by
passing `-e VAR=VALUE` to the Docker `run` command.

|    Name                   |    Description                   |    Value |
| :------------------------ | ---------------------------------| ---------|
|  `ACCEPT_EULA`            | Accept the EULA                  | -        |
|  `SA_PASSWORD`            | Password for 'admin' account     | -        |
|  `MSSQL_PID`              | Product ID or Edition            | Developer|

Usage
---------------------------------

For this, we will assume that you are using the `ecwpz91/mssql-2019-ubi8`
image.

### Mount volume

The following command initializes a standalone Microsoft SQL Server 2019 
instance with an admin user and stores the data on the host file system.

```
export DOCKER_ARGS="-e ACCEPT_EULA=Y \
                    -e SA_PASSWORD=<password> \
                    -v /home/user/database:/var/opt/mssql/data:Z"

docker run -d ${DOCKER_ARGS} --name mssql ecwpz91/mssql-2019-ubi8
```

If you are re-attaching the volume to another container, the creation of the
database user and admin user will be skipped and only the standalone 
Microsoft SQL Server 2019 instance will be started.

**Notice: When mounting data locally, ensure that the mount point has the right
permissions by checking that the owner/group matches the user private group
(UPG) inside the container.**

### Custom configuration

The following command initializes a standalone Microsoft SQL Server 2019 instance with a
configuration file already stored on the host file system.

```
export DOCKER_ARGS="-e ACCEPT_EULA=Y \
                    -e SA_PASSWORD=<admin_password> \
                    -v /home/user/mssql.conf:/var/opt/mssql/mssql.conf:Z"

docker run -d ${DOCKER_ARGS} ecwpz91/mssql-2019-ubi8
```

### Update credentials

The following commands initializes a standalone Microsoft SQL Server 2019 instance and then resets
the 'default SQL Authentication' account password. The default user name in these cases is 'sa', 
and the default password is 'blank'.

```
export DOCKER_ARGS="-e ACCEPT_EULA=Y -e SA_PASSWORD=<admin_password>"

docker run -d ${DOCKER_ARGS} --name mssql ecwpz91/mssql-2019-ubi8

docker exec mssql bash -c "-e SA_PASSWORD=<new_admin_password>"

docker restart mssql
```

**Notice: Changing database passwords directly in Microsoft SQL Server 2019 will cause a mismatch
between the values stored in the variables and the actual passwords. Whenever a
database container starts it will reset the passwords to the values stored in
the environment variables.**
