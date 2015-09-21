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

echo "Installing Drupal contrib modules" 
cd "$DRUPAL_HOME"/sites/all/modules
drush dl i18n admin_menu advanced_help block_class entity entityreference exclude_node_title extlink feeds git_deploy image_link_formatter linkchecker securelogin views_slideshow views_slideshow_galleria openid_selector
# Install openid-selector in libraries directory
cd "$DRUPAL_HOME"/sites/all/libraries
wget https://openid-selector.googlecode.com/files/openid-selector-1.3.zip
unzip openid-selector-1.3.zip
rm openid-selector-1.3.zip
cd "$DRUPAL_HOME"/sites/all/modules
# Enable the modules
drush en i18n admin_menu advanced_help block_class entity entityreference exclude_node_title extlink feeds git_deploy image_link_formatter linkchecker securelogin views_slideshow views_slideshow_galleria openid_selector
