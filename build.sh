#!/usr/bin/env bash

if [ ! -e build_dir ]; then
  echo "Making build directory"
  mkdir build_dir
fi

cd build_dir

if [ ! -e nwjs-v0.12.0-osx-x64.zip ]; then
   echo "Downloading NWJS"
   curl -L -O http://dl.nwjs.io/v0.12.0/nwjs-v0.12.0-osx-x64.zip
fi

if [ ! -e bootstrap-3.3.4-dist.zip ]; then
  echo "Downloading Bootstrap"
  curl -L -O https://github.com/twbs/bootstrap/releases/download/v3.3.4/bootstrap-3.3.4-dist.zip
fi

if [ ! -e riak-2.0.5-OSX-x86_64.tar.gz ]; then
  echo "Downloading Riak"
  curl -L -O http://s3.amazonaws.com/downloads.basho.com/riak/2.0/2.0.5/osx/10.8/riak-2.0.5-OSX-x86_64.tar.gz
fi

if [ ! -e nwjs-v0.12.0-osx-x64 ]; then
  echo "Extracting NWJS app"
  unzip nwjs-v0.12.0-osx-x64.zip
fi

if [ ! -e Riak.app ]; then
  echo "Moving Riak.app into place"
  mv nwjs-v0.12.0-osx-x64/nwjs.app Riak.app
fi

if [ ! -e Riak.app/Contents/Resources/app.nw ]; then
  echo "Copying app contents"
  cp -R ../app.nw Riak.app/Contents/Resources
fi

if [ ! -e Riak.app/Contents/Resources/riak-2.0.5 ]; then
  echo "Extracting Riak"
  ( cd Riak.app/Contents/Resources; tar -xzf ../../../riak-2.0.5-OSX-x86_64.tar.gz )
fi

if [ ! -e bootstrap-3.3.4-dist ]; then
  echo "Extracting Bootstrap"
  unzip bootstrap-3.3.4-dist.zip
fi

if [ ! -e Riak.app/Contents/Resources/app.nw/js/bootstrap.js ]; then
  echo "Moving bootstrap into app"
  cp -R bootstrap-3.3.4-dist/js Riak.app/Contents/Resources/app.nw
  cp -R bootstrap-3.3.4-dist/css Riak.app/Contents/Resources/app.nw
  cp -R bootstrap-3.3.4-dist/fonts Riak.app/Contents/Resources/app.nw
fi

if [ ! -e Riak.app/Contents/Resources/app.nw/js/jquery.min.js ]; then
  ( cd Riak.app/Contents/Resources/app.nw/js; curl -O -L http://code.jquery.com/jquery.min.js )
fi

cp ../Info.plist Riak.app/Contents/

cp ../riak.conf Riak.app/Contents/Resources/riak-2.0.5/etc/

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
