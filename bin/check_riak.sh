#!/bin/bash

pid=$(pgrep beam.smp)

if [ "$pid" != "" ]; then
  echo "Riak Running"
else
  echo "Riak Stopped"
fi