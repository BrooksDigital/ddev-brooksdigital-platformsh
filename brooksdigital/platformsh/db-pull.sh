#!/bin/bash
#ddev-generated

set -e -o pipefail

environment=${DDEV_BROOKSDIGITAL_PLATFORMSH_PRODUCTION_BRANCH-master}
cmd_environment="-e $environment"
download=true
while getopts ":ne:" option; do
  case ${option} in
    n)
      download=
      ;;
    e)
      environment=$OPTARG
      cmd_environment="-e $environment"
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

filename=dump-$environment.sql.gz

if [[ "$download" == "true"  ]]; then
  echo "Fetching database to $filename..."
  platform -y db:dump $cmd_environment --gzip -f $filename
fi

# Here we use the mysql database otherwise mysql alone will
# fail because 'db' will not be there once dropped.
mysql -uroot -proot -e 'DROP DATABASE IF EXISTS db' mysql
mysql -uroot -proot -e 'CREATE DATABASE db' mysql
pv $filename | gunzip | mysql

# Run all post-import-db scripts
/var/www/html/.ddev/brooksdigital/base/hooks/post-import-db.sh
