#!/bin/bash

echo "Installing Sleuthkit."

SHARED_DIR=$1

if [ -f "$SHARED_DIR/configs/variables" ]; then
  . "$SHARED_DIR"/configs/variables
fi

# Set apt-get for non-interactive mode
export DEBIAN_FRONTEND=noninteractive

# Dependencies
apt-get install libafflib-dev afflib-tools libewf-dev ewf-tools -y --force-yes

# Clone and compile Sleuthkit
# TODO: https://github.com/sleuthkit/sleuthkit/pull/352/files
cd /tmp
git clone -b master https://github.com/sleuthkit/sleuthkit.git
#modify /tmp/sleuthkit/bindings/java/ivysettings.xml
#modify /tmp/sleuthkit/bindings/java/ivy.xml
cd sleuthkit && ./bootstrap && ./configure && make && make install && ldconfig
