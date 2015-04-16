#!/usr/bin/env bash

RIAK_PACKAGE_URL="http://s3.amazonaws.com/downloads.basho.com/riak/2.1/2.1.0/osx/10.8"
RIAK_PACKAGE="riak-2.1.0-OSX-x86_64.tar.gz"
RIAK_DIR="riak-2.1.0"
RIAK_DMG="Riak210.dmg"

if [ ! -e build_dir ]; then
  echo "Making build directory"
  mkdir build_dir
fi

if [ ! -e deps ]; then
  echo "Making deps directory"
  mkdir deps
fi

cd deps

if [ ! -e nwjs-v0.12.0-osx-x64.zip ]; then
   echo "Downloading NWJS"
   curl -L -O http://dl.nwjs.io/v0.12.0/nwjs-v0.12.0-osx-x64.zip
fi

if [ ! -e $RIAK_PACKAGE ]; then
  echo "Downloading Riak"
  curl -L -O $RIAK_PACKAGE_URL/$RIAK_PACKAGE
fi

if [ ! -e nwjs-v0.12.0-osx-x64 ]; then
  echo "Extracting NWJS app"
  unzip nwjs-v0.12.0-osx-x64.zip
fi

cd ../build_dir

if [ ! -e Riak.app ]; then
  echo "Moving Riak.app into place"
  cp -R ../deps/nwjs-v0.12.0-osx-x64/nwjs.app Riak.app
fi

if [ ! -e Riak.app/Contents/Resources/app.nw ]; then
  echo "Copying app contents"
  cp -R ../app.nw Riak.app/Contents/Resources
fi

if [ ! -e Riak.app/Contents/Resources/$RIAK_DIR ]; then
  echo "Extracting Riak"
  ( cd Riak.app/Contents/Resources; tar -xzf ../../../../deps/$RIAK_PACKAGE )
fi

echo "Replacing version string"
sed 's/__RIAK_DIR__/'$RIAK_DIR'/g' ../app.nw/index.html > Riak.app/Contents/Resources/app.nw/index.html
sed 's/__RIAK_DIR__/'$RIAK_DIR'/g' ../app.nw/js/main.js > Riak.app/Contents/Resources/app.nw/js/main.js
sed 's/__RIAK_DMG__/'$RIAK_DMG'/g' ../README.md.template > ../README.md
sed 's/__RIAK_DMG__/'$RIAK_DMG'/g' ../deploy.sh.template > ../deploy.sh

cp ../Info.plist Riak.app/Contents/

cp ../riak.conf Riak.app/Contents/Resources/$RIAK_DIR/etc/

cp ../bin/* Riak.app/Contents/Resources/$RIAK_DIR/bin/

cp ../nw.icns Riak.app/Contents/Resources/

if which appdmg > /dev/null 2>&1; then

  if [ -e $RIAK_DMG ]; then
    echo "$RIAK_DMG exists, skipping dmg build"
  else
    appdmg ../Riak.dmg.json $RIAK_DMG
    echo "$RIAK_DMG built in build_dir"
  fi

else

  echo "#####################################################"
  echo "Install appdmg to build dmg file"
  echo "    i.e. npm install appdmg"
  echo "    more info: https://github.com/LinusU/node-appdmg"
  echo "#####################################################"

fi

cd ..

echo "Riak App built in build_dir"
