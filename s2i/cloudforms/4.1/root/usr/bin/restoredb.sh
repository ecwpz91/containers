#!/bin/bash
DBASE="vmdb_production"

echo "Drop database"
dropdb --no-password -U root $DBASE

echo "Create database"
createdb --no-password -U root $DBASE

echo "Restore database"
pg_restore --no-password -U root -d $DBASE "/tmp/"$DBASE"_latest.dump"

echo "Remove database dump file"
rm -rf "/tmp/"$DBASE"_latest.dump"

echo "Set admin credentials"
/var/www/miq/vmdb/script/rails r "User.find_by_userid('admin').update_attributes(:password => 'smartvm')"
