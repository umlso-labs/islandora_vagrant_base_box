#!/bin/bash

echo "Installing Drupal themes" 

cd "$DRUPAL_HOME"/sites/all
if [ ! -d themes ]; then
  mkdir themes
fi

cd "$DRUPAL_HOME"/sites/all/themes
while read LINE; do
	set -- $LINE 
	git clone $1 $2
	cd $2
	git checkout $3
	git checkout $4
	#Do we need the following line for each theme?
	git config core.filemode false
	cd "$DRUPAL_HOME"/sites/all/themes
done < "$SHARED_DIR"/configs/islandora-theme-list-umlso.txt