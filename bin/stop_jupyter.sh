#!/bin/bash
source ../python/bin/activate
PID=$(../python/bin/jupyter notebook list --json 2>/dev/null | python -c 'import json,sys;obj=json.load(sys.stdin);print obj["pid"];' 2>/dev/null)
if [ $? -eq 0 ]; then
  kill $PID
fi
