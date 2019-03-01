#!/bin/bash

IFS=$'\n'

### REPOSITORY is current working directory
REPOSITORY=`pwd`
cd "$REPOSITORY/"

### Get source from info.json
### https://stedolan.github.io/jq/
source=`cat info.json|jq -r .source`
source+=".git"
echo url=$source

### Pause function until enter key is pressed
function pause(){
  read -p "$*"
}

### https://git-scm.com/
git clone $source ./clone_from_source

pause 'Press [Enter] key to continue...'
