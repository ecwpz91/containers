#!/bin/bash

function standalone() {
  mongod $mongo_common_args &
  wait_for_mongo_up

  # Create admin user
  js_command="db.system.users.count({'user':'admin'})"
  if [[ "$(mongo admin --quiet --eval "$js_command")" == "1" ]]; then
    echo "=> Admin user is already created. Resetting password ..."
    mongo_reset_admin
  else
    mongo_create_admin
  fi

  # Create default user
  if [[ -v CREATE_USER ]]; then
    js_command="db.system.users.count({'user':'${MONGODB_USER}', 'db':'${MONGODB_DATABASE}'})"
    if [ "$(mongo admin --quiet --eval "$js_command")" == "1" ]; then
      echo "=> MONGODB_USER user is already created. Resetting password ..."
      mongo_reset_user
    else
      mongo_create_user
    fi
  fi

  # Restart daemon (bind all interfaces)
  mongod $mongo_common_args --shutdown
  wait_for_mongo_down

  # Make sure env variables don't propagate to mongod process.
  unset MONGODB_USER MONGODB_PASSWORD MONGODB_DATABASE MONGODB_ADMIN_PASSWORD

  # Start with access control
  mongod $mongo_common_args --auth
}
