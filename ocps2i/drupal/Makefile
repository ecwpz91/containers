# Variables are documented in hack/build.sh.
BASE_IMAGE_NAME = drupal
VERSIONS = 93
OPENSHIFT_NAMESPACES = 2.4

# HACK:  Ensure that 'git pull' for old clones doesn't cause confusion.
# New clones should use '--recursive'.
.PHONY: $(shell test -f common/common.mk || echo >&2 'Please do "git submodule update --init" first.')

include common/common.mk
