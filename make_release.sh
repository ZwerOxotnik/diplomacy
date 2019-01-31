#!/bin/bash
### Run this script after committing an updated info.json to automatically tag the update and prepare a zip of it.

IFS=$'\n'

### REPOSITORY is current working directory
REPOSITORY=`pwd`
cd "$REPOSITORY/"

### Get mod name and version and factorio_version and gitlab from info.json
### https://stedolan.github.io/jq/
mod_name=`cat info.json|jq -r .name`
mod_ver=`cat info.json|jq -r .version`
game_ver=`cat info.json|jq -r .factorio_version`
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
### Create git tag for this version
git tag "$mod_ver"

### Update remote $gitlab with tag $mod_ver
#git push "$gitlab" "$mod_ver"

### Prepare zip for Factorio native use and mod portal
name="${mod_name}_$mod_ver"
git archive --format zip --prefix "$name/" --output "../$name.zip" "$game_ver"

pause 'Press [Enter] key to continue...'
