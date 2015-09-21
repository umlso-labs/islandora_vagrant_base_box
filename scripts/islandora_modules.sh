#!/bin/bash

echo "Installing all Islandora Foundation modules"

SHARED_DIR=$1

if [ -f "$SHARED_DIR/configs/variables" ]; then
  . "$SHARED_DIR"/configs/variables
fi


# Make sure libraries folder exists (Some modules might install libraries automatically)
if [ ! -d "$DRUPAL_HOME/sites/all/libraries" ]; then
	sudo mkdir -p "$DRUPAL_HOME/sites/all/libraries"
fi

# Permissions and ownership
sudo chown -hR vagrant:www-data "$DRUPAL_HOME"/sites/all/libraries
sudo chown -hR vagrant:www-data "$DRUPAL_HOME"/sites/all/modules
sudo chown -hR vagrant:www-data "$DRUPAL_HOME"/sites/default/files
sudo chmod -R 755 "$DRUPAL_HOME"/sites/all/libraries
sudo chmod -R 755 "$DRUPAL_HOME"/sites/all/modules
sudo chmod -R 755 "$DRUPAL_HOME"/sites/default/files

# Clone all Islandora Foundation modules
cd "$DRUPAL_HOME"/sites/all/modules/
while read LINE; do
	if [ "$LINE" == "" ]; then
		continue
	fi
	set -- $LINE 
	git clone $1 $2
	cd $2
	git checkout $3
	git checkout $4
	git config core.filemode false
	cd "$DRUPAL_HOME"/sites/all/modules
done < "$SHARED_DIR"/configs/islandora-module-list-sans-tuque-umlso.txt

# Get umkc_islandora_browse manually b/c it has different directory structure
cd "$DRUPAL_HOME"/sites/all/modules/
git clone --branch 7.x https://github.com/philred/umkc_islandora_browse.git umkc_islandora_browse 
cd umkc_islandora_browse 
git checkout d892d06
mv modules/* "$DRUPAL_HOME"/sites/all/modules/
cd "$DRUPAL_HOME"/sites/all/modules/
rm -r umkc_islandora_browse 

# Clone oauth 
cd "$DRUPAL_HOME"/sites/all/modules/
git clone --branch 7.x-3.x http://git.drupal.org/project/oauth.git oauth
cd oauth 
git config core.filemode false
cd "$DRUPAL_HOME"/sites/all/modules/

# Clone node export 
cd "$DRUPAL_HOME"/sites/all/modules/
git clone --branch 7.x-3.x http://git.drupal.org/project/node_export.git
cd node_export
git config core.filemode false
cd "$DRUPAL_HOME"/sites/all/modules/

# Clone libraries
cd "$DRUPAL_HOME"/sites/all/libraries
while read LINE; do
	set -- $LINE 
	git clone $1 $2
	cd $2
	git checkout $3
	git checkout $4
	git config core.filemode false
	cd "$DRUPAL_HOME"/sites/all/libraries
done < "$SHARED_DIR"/configs/islandora-library-list-umlso.txt

# Install some libraries manually (don't have specific branch/commit to checkout)
cd "$DRUPAL_HOME"/sites/all/libraries
git clone https://github.com/nihilanth41/galleria.git galleria 
git clone https://github.com/nihilanth41/jodconverter.git jodconverter-2.2.2 
git clone https://github.com/nihilanth41/jquery-cycle.git jquery.cycle 
git clone https://github.com/nihilanth41/jwplayer.git jwplayer 

# Install plupload 1.x 
git clone -b 1.x https://github.com/moxiecode/plupload.git 
# Remove examples/ directory for security reasons 
rm -rf plupload/examples

# Get openseadragon-plugin 
cd "$DRUPAL_HOME"/sites/all/libraries
wget http://openseadragon.github.io/releases/openseadragon-bin-0.9.129.zip
unzip openseadragon-bin-0.9.129.zip 
# Directory must be: $DRUPAL_HOME/sites/all/libraries/openseadragon
mv openseadragon-bin-0.9.129 openseadragon 
cd "$DRUPAL_HOME"/sites/all/libraries

# Check for a user's .drush folder, create if it doesn't exist
if [ ! -d "$HOME_DIR/.drush" ]; then
  mkdir "$HOME_DIR/.drush"
  sudo chown vagrant:vagrant "$HOME_DIR"/.drush
fi

# Move OpenSeadragon drush file to user's .drush folder
if [ -d "$HOME_DIR/.drush" -a -f "$DRUPAL_HOME/sites/all/modules/islandora_openseadragon/islandora_openseadragon.drush.inc" ]; then
  mv "$DRUPAL_HOME/sites/all/modules/islandora_openseadragon/islandora_openseadragon.drush.inc" "$HOME_DIR/.drush"
fi

# Move video.js drush file to user's .drush folder
if [ -d "$HOME_DIR/.drush" -a -f "$DRUPAL_HOME/sites/all/modules/islandora_videojs/islandora_videojs.drush.inc" ]; then
  mv "$DRUPAL_HOME/sites/all/modules/islandora_videojs/islandora_videojs.drush.inc" "$HOME_DIR/.drush"
fi

# Move pdf.js drush file to user's .drush folder
if [ -d "$HOME_DIR/.drush" -a -f "$DRUPAL_HOME/sites/all/modules/islandora_pdfjs/islandora_pdfjs.drush.inc" ]; then
  mv "$DRUPAL_HOME/sites/all/modules/islandora_pdfjs/islandora_pdfjs.drush.inc" "$HOME_DIR/.drush"
fi

# Move IA Bookreader drush file to user's .drush folder
if [ -d "$HOME_DIR/.drush" -a -f "$DRUPAL_HOME/sites/all/modules/islandora_internet_archive_bookreader/islandora_internet_archive_bookreader.drush.inc" ]; then
  mv "$DRUPAL_HOME/sites/all/modules/islandora_internet_archive_bookreader/islandora_internet_archive_bookreader.drush.inc" "$HOME_DIR/.drush"
fi

cd "$DRUPAL_HOME"/sites/all/modules
drush -y -u 1 en php_lib islandora objective_forms
drush -y -u 1 en islandora_solr islandora_solr_metadata islandora_solr_facet_pages islandora_solr_views 
drush -y -u 1 en islandora_basic_collection islandora_pdf islandora_audio islandora_book islandora_compound_object islandora_entities islandora_basic_image islandora_large_image islandora_newspaper islandora_video islandora_web_archive islandora_document
drush -y -u 1 en islandora_premis islandora_checksum islandora_checksum_checker
drush -y -u 1 en islandora_book_batch islandora_pathauto islandora_pdfjs islandora_videojs
drush -y -u 1 en xml_forms islandora_scholar
drush -y -u 1 en islandora_fits islandora_ocr islandora_oai islandora_marcxml islandora_xacml_editor islandora_xmlsitemap islandora_internet_archive_bookreader islandora_bagit islandora_batch islandora_newspaper_batch 
drush -y -u 1 en google_analytics_reports islandora_bookmark islandora_bulk_operations islandora_ga_reports islandora_image_annotation islandora_importer islandora_ip_embargo islandora_jodconverter islandora_jwplayer islandora_mapping islandora_openseadragon islandora_paged_content islandora_plupload islandora_simple_workflow
drush -y -u 1 en umkcdora umkc_feature_types topics_and_types umkc_content_types umkc_browse

cd "$DRUPAL_HOME"/sites/all/modules

# Set variables for Islandora modules
drush eval "variable_set('islandora_audio_viewers', array('name' => array('none' => 'none', 'islandora_videojs' => 'islandora_videojs'), 'default' => 'islandora_videojs'))"
drush eval "variable_set('islandora_fits_executable_path', '$FITS_HOME/fits-$FITS_VERSION/fits.sh')"
drush eval "variable_set('islandora_lame_url', '/usr/bin/lame')"
drush eval "variable_set('islandora_video_viewers', array('name' => array('none' => 'none', 'islandora_videojs' => 'islandora_videojs'), 'default' => 'islandora_videojs'))"
drush eval "variable_set('islandora_video_ffmpeg_path', '/usr/local/bin/ffmpeg')"
drush eval "variable_set('islandora_book_viewers', array('name' => array('none' => 'none', 'islandora_internet_archive_bookreader' => 'islandora_internet_archive_bookreader'), 'default' => 'islandora_internet_archive_bookreader'))"
drush eval "variable_set('islandora_book_page_viewers', array('name' => array('none' => 'none', 'islandora_openseadragon' => 'islandora_openseadragon'), 'default' => 'islandora_openseadragon'))"
drush eval "variable_set('islandora_large_image_viewers', array('name' => array('none' => 'none', 'islandora_openseadragon' => 'islandora_openseadragon'), 'default' => 'islandora_openseadragon'))"
drush eval "variable_set('islandora_use_kakadu', TRUE)"
drush eval "variable_set('islandora_newspaper_issue_viewers', array('name' => array('none' => 'none', 'islandora_internet_archive_bookreader' => 'islandora_internet_archive_bookreader'), 'default' => 'islandora_internet_archive_bookreader'))"
drush eval "variable_set('islandora_newspaper_page_viewers', array('name' => array('none' => 'none', 'islandora_openseadragon' => 'islandora_openseadragon'), 'default' => 'islandora_openseadragon'))"
drush eval "variable_set('islandora_pdf_create_fulltext', 1)"
drush eval "variable_set('islandora_checksum_enable_checksum', TRUE)"
drush eval "variable_set('islandora_ocr_tesseract', '/usr/bin/tesseract')"
drush eval "variable_set('islandora_batch_java', '/usr/bin/java')"
drush eval "variable_set('image_toolkit', 'imagemagick')"
drush eval "variable_set('imagemagick_convert', '/usr/bin/convert')"
