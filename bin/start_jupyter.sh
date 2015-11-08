#!/bin/bash
source ../python/bin/activate
../python/bin/jupyter notebook -y --no-browser --notebook-dir=../notebook >log/jupyter.log 2>&1 &
