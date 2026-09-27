#!/bin/bash
cd /mnt/replica
tar -h --hard-dereference -c -C new . | zstd -9 -T12 | /mnt/app2/home/tapeManagementScripts/ensuredf /mnt/app2/home/ 1600G | age -p | split --bytes=760G --suffix-length=2 --numeric-suffix - /mnt/app2/home/HDDs.tar.zstd.age.