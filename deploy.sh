#!/usr/bin/env bash

s3cmd put --acl-public build_dir/Riak211.dmg s3://riak-tools/
