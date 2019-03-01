#!/bin/bash

IFS=$'\n'

### REPOSITORY is current working directory
REPOSITORY=`pwd`
cd "$REPOSITORY/"

### Get source from info.json
### https://stedolan.github.io/jq/
gamever=`cat info.json|jq -r .factorio_version`
source=`cat info.json|jq -r .source`
source+=".git"
echo url=$source

### If source is not found, set constant
[ -z "${gamever}" ] && gamever="0.17" && echo "warning! branch=$gamever"

### Pause function until enter key is pressed
function pause(){
  read -p "$*"
}

### https://git-scm.com/
### Update [wip]
git init .
git pull $source

pause 'Press [Enter] key to continue...'
