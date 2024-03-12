#!/bin/bash
#ddev-generated

set -e -o pipefail

uli=$(drush uli $@)
echo -e "\033[1;32m"
echo $uli | boxes -d peek -p h3v1
echo -en "\033[0m"
