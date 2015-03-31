#!/usr/bin/env bash

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

if [ ! -e riak-2.0.5-OSX-x86_64.tar.gz ]; then
  echo "Downloading Riak"
  curl -L -O http://s3.amazonaws.com/downloads.basho.com/riak/2.0/2.0.5/osx/10.8/riak-2.0.5-OSX-x86_64.tar.gz
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

if [ ! -e Riak.app/Contents/Resources/riak-2.0.5 ]; then
  echo "Extracting Riak"
  ( cd Riak.app/Contents/Resources; tar -xzf ../../../../deps/riak-2.0.5-OSX-x86_64.tar.gz )
fi

cp ../Info.plist Riak.app/Contents/

cp ../riak.conf Riak.app/Contents/Resources/riak-2.0.5/etc/

cp ../bin/* Riak.app/Contents/Resources/riak-2.0.5/bin/

cp ../nw.icns Riak.app/Contents/Resources/

if which appdmg > /dev/null 2>&1; then

  if [ -e Riak205.dmg ]; then
    echo "Riak205.dmg exists, skipping dmg build"
  else
    appdmg ../Riak.dmg.json Riak205.dmg
    echo "Riak205.dmg built in build_dir"
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
