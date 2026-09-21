#!/bin/bash
if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi
cd /mnt/replica
echo "check loaded tape"
/bin/bash /mnt/app2/home/tapeManagementScripts/autoloaderReadWriteTest.sh
if [ $? -ne 0 ]; then
    echo "check failed load undamaged tape to start write"
else 
    apprise -b "tape checks successfull enter password to start backup" -t tapeEnterPassword --config ./apprise.conf
    tar -h --hard-dereference -c -C new . | age -p | mbuffer -P 95 -m 800G -T /mnt/app2/home/autoloader -s 524288 -o /dev/nst0 -A "/mnt/app2/home/tapeManagementScripts/autoLoaderNext.sh"
fi