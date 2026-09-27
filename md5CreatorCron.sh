#!/bin/bash
cd /mnt/app2/home
find . -name "*tar.zstd.age.*" -not -name "*.md5" -exec /mnt/app2/home/tapeManagementScripts/md5Hashing.sh {} +
