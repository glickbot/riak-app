#!/bin/bash

pid=$(pgrep beam.smp)
if [ "$pid" != "" ]; then
  echo "Riak Running"
else
  output=$(bin/riak start 2> /dev/null)
  if [ "$output" == "Node is already running!" ]; then
    echo "Riak Running"
  else
    if [ "$output" == "" ]; then
      bin/riak-admin wait-for-service riak_kv > /dev/null 2> /dev/null
      echo "Riak Running"
    else
      if echo "$output" | grep --quiet ulimit; then
        bin/start_jupyter.sh
        echo "Riak Running"
      else
        echo "Problem starting Riak: $output"
      fi
    fi
  fi
fi
