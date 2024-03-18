#!/bin/bash
#ddev-generated
set -e -o pipefail

USAGE=$(cat << EOM

Usage: $0 [options]

  -h                This help text
  -e ENVIRONMENT    Use a different environment to download/import database
  -n                Do not download, expect the dump to be already downloaded.
  -o                Import only, do not run post-import-db hooks
EOM
)

environment=${DDEV_BROOKSDIGITAL_PLATFORMSH_PRODUCTION_BRANCH-master}
cmd_environment="-e $environment"
download=true
post_import=true
while getopts ":hne:o" option; do
  case ${option} in
    h)
      echo "$USAGE"
      exit 0
      ;;
    n)
      download=
      ;;
    e)
      environment=$OPTARG
      cmd_environment="-e $environment"
      ;;
    o)
      post_import=
      ;;
    :)
      echo -e "\033[1;31m[error] -${OPTARG} requires an argument.\033[0m"
      echo "$USAGE"
      exit 1
      ;;
    ?)
      echo -e "\033[1;31m[error] Invalid option: -${OPTARG}.\033[0m"
      echo "$USAGE"
      exit 1
      ;;
  esac
done
shift $((OPTIND-1))

filename=dump-$environment.sql.gz

if [[ "$download" == "true"  ]]; then
  echo "Fetching database to $filename..."
  if [[ "$DDEV_PROJECT_TYPE" == *"drupal"* ]] || [[ "$DDEV_BROOKSDIGITAL_PROJECT_TYPE" == *"drupal"* ]]; then
    platform -y drush $cmd_environment -- sql-dump --gzip --structure-tables-list=${DDEV_BROOKSDIGITAL_PLATFORMSH_DRUSH_SQL_EXCLUDE-cache*,watchdog,search*} --gzip > $filename
  else
    platform -y db:dump $cmd_environment --gzip -f $filename
  fi
fi

# Here we use the mysql database otherwise mysql alone will
# fail because 'db' will not be there once dropped.
mysql -uroot -proot -e 'DROP DATABASE IF EXISTS db' mysql
mysql -uroot -proot -e 'CREATE DATABASE db' mysql
pv $filename | gunzip | mysql

if [ -n "$post_import" ]; then
  # Run all post-import-db scripts
  /var/www/html/.ddev/brooksdigital/base/hooks/post-import-db.sh
fi
