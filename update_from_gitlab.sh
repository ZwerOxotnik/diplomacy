#!/bin/bash

IFS=$'\n'

### REPOSITORY is current working directory
REPOSITORY=`pwd`
cd "$REPOSITORY/"

### Get gitlab from info.json
### https://stedolan.github.io/jq/
mod_name=`cat info.json|jq -r .name`
gamever=`cat info.json|jq -r .factorio_version`
author=`cat info.json|jq -r .author`

### If gitlab is not found, set constant
[ -z "${gamever}" ] && gamever="0.16" && echo "warning! branch=$gamever"

gitlab="https://gitlab.com/$author/$mod_name.git"
### If gitlab is not found, set constant
[ -z "${gitlab}" ] && gitlab="https://gitlab.com/ZwerOxotnik/soft-evolution.git"
echo url=$gitlab

### Pause function until enter key is pressed
function pause(){
  read -p "$*"
}

### https://git-scm.com/
### Update [wip]
git init .
git pull $gitlab

pause 'Press [Enter] key to continue...'
