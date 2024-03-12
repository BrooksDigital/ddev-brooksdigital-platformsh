#!/bin/bash
#ddev-generated

set -e -o pipefail

environment="-e ${DDEV_BROOKSDIGITAL_PLATFORMSH_PRODUCTION_BRANCH-master}"
download=true
while getopts ":ne:" option; do
  case ${option} in
    n)
      download=
      ;;
    e)
      environment="-e $OPTARG"
      ;;
    :)
      echo "Option -${OPTARG} requires an argument."
      exit 1
      ;;
    ?)
      echo "Invalid option: -${OPTARG}."
      exit 1
      ;;
  esac
done
shift $((OPTIND-1))

filename=dump-${1-$environment}.sql.gz

if [[ "$download" == "true"  ]]; then
  echo "Dumping database on remote:/tmp/$filename..."
  platform -y db:dump $environment --gzip --f $filename
fi

# Here we use the mysql database otherwise mysql alone will
# fail because 'db' will not be there once dropped.
mysql -uroot -proot -e 'DROP DATABASE IF EXISTS db' mysql
mysql -uroot -proot -e 'CREATE DATABASE db' mysql
pv $filename | gunzip | mysql

drush cr -y
drush updb -y
drush cim -y

ahoy drush:uli
