CloudForms (CFME) Container
=====================

This repository contains Dockerfiles for building CFME images on [OpenShift][1]. Supported [base image][2] GNU/Linux distributions are as follows:

[](base-image-os)

|         | <center>CentOS</center> | RHEL | Fedora |
| ------- | ----------------------- |----- | ------ |
| 4.1     | -                       | 7    | -      |
| 4.2     | -                       | 7    | -      |
| 4.5-sql     | -                       | 7    | -      |

Building CFME Images
---------------------------------

### Overview

The following section describes how to build CFME images and their required dependencies.

### Prerequisites

This repository requires [Docker][3] to build the images containing CFME. Make sure that the daemon is installed and enabled on your system before you being.

Also, you will need VPN access to download the latest [database backups][7] from the environment in the MBU lab.

**Notice: RHEL based images require a properly [subscribed][4] system. Don't have a Red Hat subscription? See [Red Hat Enterprise Linux Developer Suite][5].**

### Instructions
1. Clone a copy of the repository locally.

	```bash
	git clone git@gitlab.consulting.redhat.com/msurbey/s2i-cfme-container.git
	```

2. Change directories with `cd`.

	```bash
	cd s2i-cfme-container
	```

3. Build image from scratch.

	Fedora

	```bash
	make build TARGET=fedora VERSION=4.5
	```

	RHEL

	```bash
	make build TARGET=rhel7 VERSION=4.5
	```

	CentOS

	```bash
	make build VERSION=4.5
	```

Usage
---------------------------------

For information about usage of Dockerfile for CFME 4.1 (deprecated),
see [usage documentation](4.1/README.md).

For information about usage of Dockerfile for CFME 4.2,
see [usage documentation](4.2/README.md).

For information about usage of Dockerfile for CFME 4.5,
see [usage documentation](4.5/README.md).

Command Reference
---------------------------------

### `make build`
Build and test all provided versions of CFME.

### `make test`
Unit test all provided versions of CFME.

### `make test-openshift`
Integration test all provided versions of CFME.

#### Options

```
SKIP_SQUASH : toggle image squashing (default 0)
VERSION     : limit command scope to specific version (default all)
TARGET      : limit command scope to specific GNU/Linux distribution (default all)
```

Contributing
---------------------------------
If you want to contribute, make sure to follow the [contribution guidelines](CONTRIBUTING.md) when you open issues or submit pull requests.

[1]: https://docs.openshift.org/latest/using_images/
[2]: https://docs.docker.com/glossary/?term=base%20image
[3]: https://docs.docker.com/engine/installation/
[4]: https://access.redhat.com/solutions/253273
[5]: https://developers.redhat.com/articles/no-cost-rhel-faq/
[6]: https://help.github.com/articles/cloning-a-repository/
[7]: https://mojo.redhat.com/docs/DOC-1093580
