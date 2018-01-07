## JBoss Data Virtualization (JDV) Container

This repository contains Dockerfiles for building a standalone JDV images. Supported [base image][2] GNU/Linux distributions are as follows:

[](base-image-os)

|         | <center>CentOS</center> | RHEL | Fedora |
| ------- | ----------------------- |----- | ------ |
| 6.3     | -                       | 7    | -      |


Building JDV Images
---------------------------------

### Overview

The following section describes how to build JDV images and their required dependencies.

### Prerequisites

This repository requires [Docker][1] to build the images containing JDV. Make sure that the daemon is installed and enabled on your system before you being.

**Notice: RHEL based images require a properly [subscribed][2] system. Don't have a Red Hat subscription? See [Red Hat Enterprise Linux Developer Suite][5].**

### Instructions
1. Clone a copy of the repository locally.

	```bash
	git clone https://github.com/ecwpz91/jbossdv-container.git
	```

2. Change directories with `cd`.

	```bash
	cd jbossdv-container
	```

3. Build image from scratch.

	Fedora

	```bash
	make build TARGET=fedora VERSION=
	```

	RHEL

	```bash
	make build TARGET=rhel7 VERSION=6.3
	```

	CentOS

	```bash
	make build VERSION=
	```

 Usage
 ---------------------------------

 For information about usage of Dockerfile for JDV 6.3,
 see [usage documentation](6.3/README.md).

 Command Reference
 ---------------------------------

 ### make build
 Build and test all provided versions of JDV.

 ### make test
 Unit test all provided versions of JDV.

 ### make test-openshift
 Integration test all provided versions of JDV.

 #### Options

 ```
 SKIP_SQUASH : toggle image squashing (default 0)
 VERSION     : limit command scope to specific JDV version (default all)
 TARGET      : limit command scope to specific GNU/Linux distribution (default all)
 ```

 Contributing
 ---------------------------------
 If you want to contribute, make sure to follow the [contribution guidelines](CONTRIBUTING.md) when you open issues or submit pull requests.

## Credits

Originally inspired by [Red Hat JBoss Data Virtualization Workshop][2]. Thanks!

[1]: https://docs.docker.com/engine/installation/
[2]: https://developers.redhat.com/articles/no-cost-rhel-faq/
[3]: https://github.com/DataVirtualizationByExample/DVWorkshop
