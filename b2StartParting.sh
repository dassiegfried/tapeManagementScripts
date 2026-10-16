#!/bin/bash
cd /mnt/replica/new
tar -h --hard-dereference -c -C B2Backup . | zstd -7 -T12 | /mnt/app2/home/tapeManagementScripts/ensuredf.sh /mnt/replica/new/tapeB2BackupLocal/ 200G | age -p | split --bytes=740G --suffix-length=2 --numeric-suffix - /mnt/replica/new/tapeB2BackupLocal/B2B.tar.zstd.age.