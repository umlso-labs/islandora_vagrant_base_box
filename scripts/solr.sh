#!/bin/bash

echo "Installing Solr"

SHARED_DIR=$1

if [ -f "$SHARED_DIR/configs/variables" ]; then
  . "$SHARED_DIR"/configs/variables
fi

# Download Solr
if [ ! -f "$DOWNLOAD_DIR/apache-solr-$SOLR_VERSION.tgz" ]; then
  echo "Downloading Solr"
  wget -q -O "$DOWNLOAD_DIR/apache-solr-$SOLR_VERSION.tgz" "http://archive.apache.org/dist/lucene/solr/$SOLR_VERSION/apache-solr-$SOLR_VERSION.tgz"
fi
cd /tmp
cp "$DOWNLOAD_DIR/apache-solr-$SOLR_VERSION.tgz" /tmp
tar -xzvf apache-solr-"$SOLR_VERSION".tgz

# Prepare SOLR_HOME
if [ ! -d "$SOLR_HOME" ]; then
  mkdir "$SOLR_HOME"
fi
cd /tmp/apache-solr-"$SOLR_VERSION"/example/solr
mv -v ./* "$SOLR_HOME"
chown -hR tomcat6:tomcat6 "$SOLR_HOME"

# Deploy Solr
cp -v "/tmp/apache-solr-$SOLR_VERSION/dist/apache-solr-$SOLR_VERSION.war" "/var/lib/tomcat6/webapps/solr.war"
chown tomcat6:tomcat6 /var/lib/tomcat6/webapps/solr.war
ln -s "$SOLR_HOME" /var/lib/tomcat6/solr

# Restart Tomcat
service tomcat6 restart
