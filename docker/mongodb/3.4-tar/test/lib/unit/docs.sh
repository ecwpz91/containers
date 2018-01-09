#!/bin/bash

# test_mongo_docs() {
#   local test_name=${FUNCNAME[0]}
#   local tmpdir=$(mktemp -d)
#
#   run_container ${test_name} ${IMAGE_NAME} ${STANDALONE_ENV}
#   set_mongodb_ipv4 ${test_name}
#
#   log_info "Testing documentation in the container image"
#
#   # Extract the help files from the container
#   for f in /usr/share/container-scripts/mongodb/README.md help.1 ; do
#     docker run --rm ${IMAGE_NAME} /bin/bash -c "cat /${f}" >${tmpdir}/$(basename ${f})
#     # Check whether the files include some important information
#     for term in MONGODB_ADMIN_PASSWORD volume ; do
#       if ! cat ${tmpdir}/$(basename ${f}) | grep -q -e "${term}" ; then
#         echo "ERROR: File /${f} does not include '${term}'."
#         return 1
#       fi
#     done
#   done
#
#   # Check whether the files use the correct format
#   if ! file ${tmpdir}/help.1 | grep -q roff ; then
#     echo "ERROR: /help.1 is not in troff or groff format"
#     return 1
#   fi
# }
