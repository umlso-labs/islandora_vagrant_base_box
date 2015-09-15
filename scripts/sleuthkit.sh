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
# w/ sed
cd /tmp
git clone https://github.com/sleuthkit/sleuthkit.git
cd sleuthkit && ./bootstrap && ./configure && make && make install && ldconfig
