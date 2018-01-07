# Variables are documented in hack/build.sh.
BASE_IMAGE_NAME = jbossdv
VERSIONS = 6.3
OPENSHIFT_NAMESPACES = 2.4

.PHONY: $(shell test -f 6.3/software/jboss-dv-6.3.0-installer.jar || echo >&2 'Please download jboss-dv-6.3.0-installer.jar first.')

# HACK:  Ensure that 'git pull' for old clones doesn't cause confusion.
# New clones should use '--recursive'.
.PHONY: $(shell test -f common/common.mk || echo >&2 'Please do "git submodule update --init" first.')

include common/common.mk
