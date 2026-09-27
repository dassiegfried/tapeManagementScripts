#!/bin/bash
cd /mnt/replica/new
tar -h --hard-dereference -c -C B2Backup . | zstd -9 -T12 | /mnt/app2/home/tapeManagementScripts/ensuredf.sh /mnt/app2/home/ 200G | age -p | split --bytes=760G --suffix-length=2 --numeric-suffix - /mnt/app2/home/B2B.tar.zstd.age.