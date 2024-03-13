#!/bin/bash
#ddev-generated
set -e -o pipefail

if [[ "$DDEV_PROJECT_TYPE" == *"drupal"* ]] || [[ "$DDEV_BROOKSDIGITAL_PROJECT_TYPE" == *"drupal"* ]]; then
  uli=$(drush uli "$@")
  echo -e "\033[1;32m"
  echo $uli | boxes -d peek -p h3v1
  echo -en "\033[0m"
else
  echo -en "\033[1;31mNot drupal!\033[0m"
  exit 1
fi
