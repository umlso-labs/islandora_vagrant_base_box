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
cd /tmp
#sleuthkit HEAD won't build presumably b/c of java6, so we switch back to master branch
git clone -b master https://github.com/sleuthkit/sleuthkit.git
cd /tmp/sleuthkit/bindings/java
sed -i.bak s/3.8.0-SNAPSHOT/latest.integration/g ivy.xml
#Delete the following two lines to fix the build
sed -i.bak '/<ibiblio name="xerial" m2compatible="true"/d' ivysettings.xml
sed -i.bak '/root="http:\/\/oss.sonatype.org\/content\/repositories\/snapshots"\/>/d' ivysettings.xml
cd /tmp/sleuthkit && ./bootstrap && ./configure && make && make install && ldconfig
