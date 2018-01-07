#!/bin/bash
DBFILE=""

echo "Drop database"
dropdb --no-password -U root $DBFILE

echo "Create database"
createdb --no-password -U root $DBFILE

echo "Restore database"
pg_restore --no-password -U root -d $DBFILE "/tmp/$DBFILE\_latest.dump"

echo "Remove database dump file"
rm -rf "/tmp/$DBFILE\_latest.dump"

echo "Set admin credentials"
/var/www/miq/vmdb/script/rails r "User.find_by_userid('admin').update_attributes(:password => 'smartvm')"
