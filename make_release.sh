#!/bin/bash
### Run this script after committing an updated info.json to automatically tag the update and prepare a zip of it.

IFS=$'\n'

### REPOSITORY is current working directory
REPOSITORY=`pwd`
cd "$REPOSITORY/"

### Get mod name and version and factorio_version and source from info.json
### https://stedolan.github.io/jq/
mod_name=`cat info.json|jq -r .name`
mod_ver=`cat info.json|jq -r .version`
game_ver=`cat info.json|jq -r .factorio_version`
source=`cat info.json|jq -r .source`
source+=".git"
echo url=$source

### Pause function until enter key is pressed
function pause(){
  read -p "$*"
}

### https://git-scm.com/
### Create git tag for this version
git tag "$mod_ver"

### Update remote $source with tag $mod_ver
#git push "$source" "$mod_ver"

### Prepare zip for Factorio native use and mod portal
name="${mod_name}_$mod_ver"
git archive --format zip --prefix "$name/" --output "../$name.zip" "$game_ver"

pause 'Press [Enter] key to continue...'
