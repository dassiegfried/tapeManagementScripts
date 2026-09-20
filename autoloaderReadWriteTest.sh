#!/bin/bash
cd /mnt/app2/home/tapeManagementScripts/
md5Source=$(cat 10G.md5 | cut -d " " -f 1)
cat 10G.md5 && cat 10G | sudo mbuffer -o /dev/nst0 -H && sudo mt -f /dev/nst0 weof 1 && sudo mt -f /dev/nst0 asf 0 && echo "tape spooled to pos 0" && sudo mbuffer -i /dev/nst0 -H | md5sum > tapeReadWriteTest.md5
md5FromTape=$(cat tapeReadWriteTest.md5 | cut -d " " -f 1)
if [ "$md5Source" = "$md5FromTape" ]; then
    echo "md5 sums match read write SUCCESS can continue normaly"
    exit 0
else
    echo "FAILED! md5 sums MISSMATCH! please insert usable tape"
    apprise -b "tape check failed" -t tapeChecks --config ./apprise.conf
    exit 1
fi
