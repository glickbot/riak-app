#!/bin/bash

output=$(bin/riak stop 2> /dev/null)
pid=""

if [ "$output" == "Node is not running!" ]; then
  pid=$(pgrep beam.smp)
fi

if [ "$pid" != "" ]; then
  kill -9 $pid
fi

echo "Riak Stopped"