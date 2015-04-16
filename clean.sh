#!/usr/bin/env bash

if [ -e build_dir ]; then
  echo "Cleaning build_dir"
  rm -rf build_dir/*
fi

if [ -e deps ]; then
  echo "Removing old version of Riak"
  rm -rf deps/riak-*
fi

echo "Done"