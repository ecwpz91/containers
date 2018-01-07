# s2i Containers

This is a repository of custom `s2i` projects, as well as a wrapper script for
Source-to-Image (S2I) source repositories that use common build helpers for
[sclorg][1] containers.

## What is this repository for?

Storing custom `s2i` containers.

Due to the recent news of the [buildah][2] toolkit for building reproducible OCI
images, I'm disinterested in `s2i` tooling going forward.

## What is the wrapper script?

Source-to-Image (S2I) is a great toolkit and workflow for building reproducible
Docker images from source code, but it lacks some really interesting features
to be productive from a developer’s perspective. This script helps developers
with their casual/daily worksflows while using `s2i create` as the internal tool.

For instance, `s2ic <imageName> <destination>` will perform the following:
- Setup common build helpers for [sclorg][3] containers
- Add a `.gitignore` to the newly created project space
- Remove the default Makefile created by `s2i create`
- Beautify the s2i usage shell script
- Add project name and version to the usage shell script
- Create a default Dockerfile that uses upstream tarballs, and adds support for
arbitrary user IDs, etc.
- Adds a default `scl_enable` to the project
- Initializes a template README for the project
- Adds the default CentOS container index file `cccp.yml`

## Install

The easiest way is to clone this repository, so you can just update the script
via the `git pull` command.

#### Linux

```sh
git clone https://msurbey@gitlab.consulting.redhat.com/msurbey/s2ic.git
cd s2ic/bin/
chmod +x s2ic
echo 'PATH=$PWD/s2ic:$PATH' >> $HOME/.bash_profile
source $HOME/.bash_profile
```

### Usage

```sh
s2ic cloudforms-00-centos7 $(PWD)/cf/
```

OR

```sh
s2ic cloudforms-00-centos7 cf/
```

[1]: https://github.com/sclorg
[2]: https://github.com/projectatomic/buildah
[3]: https://github.com/sclorg/container-common-scripts
