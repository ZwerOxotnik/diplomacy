#!/bin/bash

IFS=$'\n'

### REPOSITORY is current working directory
REPOSITORY=`pwd`
cd "$REPOSITORY/"

### Get gitlab from info.json
### https://stedolan.github.io/jq/
mod_name=`cat info.json|jq -r .name`
author=`cat info.json|jq -r .author`
gitlab="https://gitlab.com/$author/$mod_name.git"


### If gitlab is not found, set constant
[[ -z "${gitlab}" || -z "${mod_name}" || -z "${author}" ]] && gitlab="https://gitlab.com/ZwerOxotnik/soft-evolution.git"
echo url=$gitlab

### Pause function until enter key is pressed
function pause(){
  read -p "$*"
}

### https://git-scm.com/
git clone $gitlab ./clone_from_gitlab

pause 'Press [Enter] key to continue...'
