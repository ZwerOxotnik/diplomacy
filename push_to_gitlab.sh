#!/bin/bash

IFS=$'\n'

### REPOSITORY is current working directory
REPOSITORY=`pwd`
cd "$REPOSITORY/"

### Get gamever and source from info.json
### https://stedolan.github.io/jq/
gamever=`cat info.json|jq -r .factorio_version`
source=`cat info.json|jq -r .source`
source+=".git"
echo url=$source
echo

### Pause function until enter key is pressed
function pause(){
  read -p "$*"
}

### https://git-scm.com/
### Find .git and update source
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
  ### Update remote $source refs along with associated objects $gamever
  git push $source $gamever
  echo "Done at `date`"
else
  echo "Skipping because it doesn't look like it has a .git folder. `date`"
fi

pause 'Press [Enter] key to continue...'
