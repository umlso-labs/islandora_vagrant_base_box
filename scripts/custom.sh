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

# Install GMP library (Recommended by OpenID module for php) 
sudo apt-get -y install php5-gmp 
sudo service apache2 restart 

# Create ctools/css and set permissions
cd "$DRUPAL_HOME"/sites/all
mkdir -p files/ctools/css 
chmod 777 files/ctools/css

echo "Installing Drupal contrib modules" 
cd "$DRUPAL_HOME"/sites/all/modules
drush -y dl job_scheduler i18n admin_menu advanced_help block_class entity entityreference exclude_node_title extlink feeds git_deploy image_link_formatter linkchecker securelogin views_slideshow views_slideshow_galleria openid_selector

# Install openid-selector in libraries directory
cd "$DRUPAL_HOME"/sites/all/libraries
wget https://openid-selector.googlecode.com/files/openid-selector-1.3.zip
unzip openid-selector-1.3.zip
rm openid-selector-1.3.zip

# Install glip library (needed by git_deploy) 
cd "$DRUPAL_HOME"/sites/all/libraries
git clone git://github.com/halstead/glip.git glip 
cd glip 
git checkout 1.1 

# Enable the modules
cd "$DRUPAL_HOME"/sites/all/modules
drush -y en i18n admin_menu job_scheduler advanced_help block_class entity entityreference exclude_node_title extlink feeds git_deploy image_link_formatter linkchecker views_slideshow views_slideshow_galleria openid_selector
# Need ssl configured for this to work; ignore for now
# drush en securelogin

# Disable toolbar module b/c it conflicts with admin_menu
 drush -y dis toolbar overlay
 
# Suppress apache2 error about ServerName 
sudo echo "ServerName localhost" >> /etc/apache2/apache2.conf

# Setup multi-site 
DOMAIN_NAME=localhost 
cd $DRUPAL_HOME
sites_arr=( lso merlin mospace mst mu umkc umsl ) 
for i in "${sites_arr[@]}"
do
	drush si -y --db-url=mysql://root:islandora@localhost/"$i" --sites-subdir="$DOMAIN_NAME.$i" --site-name="$i"
	# Set password for each site 
	cd "$DRUPAL_HOME/sites/$DOMAIN_NAME.$i"
	drush user-password admin --password=islandora
	# Create symlinks
	cd $DRUPAL_HOME
	if [ -f $i ]; then
		rm $i
	fi
	ln -s . $i 
done

# Enable islandora modules for all the sites
# Super redundant (just to test)
cd $DRUPAL_HOME
drush @sites -u 1 -y en php_lib islandora objective_forms
drush @sites -u 1 -y en islandora_solr islandora_solr_metadata islandora_solr_facet_pages islandora_solr_views
drush @sites -u 1 -y en islandora_basic_collection islandora_pdf islandora_audio islandora_book islandora_compound_object islandora_entities islandora_basic_image islandora_large_image islandora_newspaper islandora_video islandora_web_archive islandora_document
drush @sites -u 1 -y en islandora_premis islandora_checksum islandora_checksum_checker
drush @sites -u 1 -y en islandora_book_batch islandora_pathauto islandora_pdfjs islandora_videojs
drush @sites -u 1 -y en xml_forms islandora_scholar
drush @sites -u 1 -y en islandora_fits islandora_ocr islandora_oai islandora_marcxml islandora_xacml_editor islandora_xmlsitemap islandora_internet_archive_bookreader islandora_bagit islandora_batch islandora_newspaper_batch
drush @sites -u 1 -y en google_analytics_reports islandora_bookmark islandora_bulk_operations islandora_ga_reports islandora_image_annotation islandora_importer islandora_ip_embargo islandora_jodconverter islandora_jwplayer islandora_mapping islandora_openseadragon islandora_paged_content islandora_plupload islandora_simple_workflow
drush @sites -u 1 -y en umkcdora umkc_feature_types topics_and_types umkc_content_types umkc_browse
drush @sites -u 1 -y en islandora_book_batch islandora_pathauto islandora_pdfjs islandora_videojs islandora_jwplayer
drush @sites -u 1 -y en xml_forms xml_form_builder xml_schema_api xml_form_elements xml_form_api jquery_update zip_importer islandora_basic_image islandora_bibliography islandora_compound_object islandora_google_scholar islandora_scholar_embargo islandora_solr_config citation_exporter doi_importer endnotexml_importer pmid_importer ris_importer
drush @sites -u 1 -y en islandora_fits islandora_ocr islandora_oai islandora_marcxml islandora_simple_workflow islandora_xacml_api islandora_xacml_editor islandora_xmlsitemap colorbox islandora_internet_archive_bookreader islandora_bagit islandora_batch_report islandora_usage_stats islandora_form_fieldpanel islandora_altmetrics islandora_populator islandora_newspaper_batch 
drush @sites -u 1 -y en i18n admin_menu job_scheduler advanced_help block_class entity entityreference exclude_node_title extlink feeds git_deploy image_link_formatter linkchecker views_slideshow views_slideshow_galleria openid_selector
drush @sites -u 1 -y dis toolbar overlay 

# Configure filter-drupal.xml for the new site by adding connection line 
# ex <connection server="localhost" port="3306" dbname="testsite" user="root" password="islandora">
# sudo service tomcat6 restart 

# Set permissions (See: https://github.com/Islandora-Labs/islandora_vagrant/issues/76)
sudo chown -hR vagrant:www-data "$DRUPAL_HOME"/sites/all/modules
sudo chmod -R 755 "$DRUPAL_HOME"/sites/all/libraries
sudo chmod -R 755 "$DRUPAL_HOME"/sites/all/modules


# Following steps necessary for subdomain sites or if doing install manually
# Ex) test.localhost as opposed to localhost/test 
#https://www.drupal.org/node/823990
# Setup /etc/hosts 
#sudo echo "127.0.0.1 testsite.localhost" >> /etc/hosts 

# Setup Virtual Hosts (apache)
#/etc/apache2/httpd.conf -> (ubuntu)/etc/apache2/sites-available/000-default.conf

# Restart apache2 
#service apache2 restart 

# Setup database for testsite (MYSQL)
# Do this by hand (for now)

# Setup sites folders 
# Assert default/files exists 
#cd "$DRUPAL_HOME"/sites/
#if [ ! -d default/files ]; then  
#	sudo mkdir -pm 777 default/files 
#fi

# Use sites/default as the template for the new sites 
#sudo cp -a default testsite.localhost
#sudo mv testsite.localhost/default.settings.php testsite.localhost/settings.php
#sudo chmod a+w testsite.localhost/settings.php

# Replace the following with something automated ??
# Go to testsite.localhost:8000/install.php 

