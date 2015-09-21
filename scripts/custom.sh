#!/bin/bash

SHARED_DIR=$1
if [ -f "$SHARED_DIR/configs/variables" ]; then
  . "$SHARED_DIR"/configs/variables
fi

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
	#Do we need the following line for each theme?
	git config core.filemode false
	cd "$DRUPAL_HOME"/sites/all/themes
done < "$SHARED_DIR"/configs/islandora-theme-list-umlso.txt

# Create ctools/css and set permissions
cd "$DRUPAL_HOME"/sites/all
mkdir -p files/ctools/css 
chmod 777 files/ctools/css