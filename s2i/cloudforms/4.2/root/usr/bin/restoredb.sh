#!/bin/bash
DBNAME="vmdb_production"
DBFILE="/tmp/"$DBASE"_latest.dump"
PASSWD=smartvm
INTVLS=2

function pause_before_exec() {
  date; echo "Sleeping for $INTVLS seconds";echo;date
}

function execute() {
  echo
  echo "Execute: $1"
  pause_before_exec
  eval $1
}

execute "dropdb -e $DBNAME"
execute "createdb -e $DBNAME"
execute "pg_restore -vd $DBNAME $DBFILE"

pushd /var/www/miq/vmdb

execute "bundle exec tools/fix_auth.rb --v2 --invalid bogus"
execute "bin/rails r \"User.find_by_userid('admin').update_attributes(:password => '$PASSWD')\""
execute "bin/rake db:migrate"

popd
