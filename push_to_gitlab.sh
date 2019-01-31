#!/bin/bash

IFS=$'\n'

### REPOSITORY is current working directory
REPOSITORY=`pwd`
cd "$REPOSITORY/"

### Get gamever and gitlab from info.json
### https://stedolan.github.io/jq/
mod_name=`cat info.json|jq -r .name`
gamever=`cat info.json|jq -r .factorio_version`
author=`cat info.json|jq -r .author`
gitlab="https://gitlab.com/$author/$mod_name.git"

### If gitlab is not found, set constant
[[ -z "${gitlab}" || -z "${mod_name}" || -z "${author}" ]] && gitlab="https://gitlab.com/ZwerOxotnik/soft-evolution.git"
echo url=$gitlab
echo

### Pause function until enter key is pressed
function pause(){
  read -p "$*"
}

### https://git-scm.com/
### Find .git and update gitlab
echo "update for $REPOSITORY/.git at `date`"
if [ -d "$REPOSITORY/.git" ]
then
  ### Switch branches or restore working tree files
  #git checkout $gamever
  echo
  echo "status:"
  git status
  echo
  #git status --branch $gamever
  echo "pushing:"
  ### Update remote $gitlab refs along with associated objects $gamever
  git push $gitlab $gamever
  echo "Done at `date`"
else
  echo "Skipping because it doesn't look like it has a .git folder. `date`"
fi

pause 'Press [Enter] key to continue...'
