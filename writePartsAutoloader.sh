#!/bin/bash
#!/bin/bash
if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi
cd /mnt/replica/new/tapeB2BackupLocal
echo "check loaded tape"
if [ -f firstStart ]; then
    sleep 1
else
    echo "this is the first time the script is called testing tape"
    /bin/bash /mnt/app2/home/tapeManagementScripts/tapeChecks.sh
    if [ $? -ne 0 ]; then
        echo "check failed load undamaged tape to start write"
        exit 1
    else 
        touch firstStart
    fi
fi


partName=$(ls | grep tar.zstd.age. | grep -v .md5 | head -n 1)
echo "file named $partName selected"
if [ -f $partName ]; then
    echo "file exists can continue"
else
    echo "tartgeted file $partName dosnt exists!"
    apprise --tag crit -b "tartgeted file $partName dosnt exists!" -t missingFile --config /mnt/app2/home/tapeManagementScripts/apprise.conf
fi
echo "starting write to tape"
nice -n -10 ionice -c 1 cat $partName | mbuffer -H -P 95 -s 64k -m 100G -T /mnt/app2/home/mbufferCache.bin -o /dev/nst0 --tapeaware -A "/mnt/app2/home/tapeManagementScripts/noNextTape.sh" && mt -f /dev/nst0 weof 1 && sudo mt -f /dev/nst0 asf 0 && echo "tape Right spooled to pos 0" 
if [ $? -ne 0 ]; then
    apprise --tag crit -b "first write failed" -t tapeChecks --config /mnt/app2/home/tapeManagementScripts/apprise.conf
    echo "first write failed"   
    exit 1
fi
echo "first write successfull"
echo "loading second copy tape"
/bin/bash /mnt/app2/home/tapeManagementScripts/autoLoaderNext.sh
nice -n -10 ionice -c 2 cat $partName | mbuffer -H -P 95 -s 64k -m 100G -T /mnt/app2/home/mbufferCache.bin -o /dev/nst0 --tapeaware -A "/mnt/app2/home/tapeManagementScripts/noNextTape.sh" &&  mt -f /dev/nst0 weof 1 && sudo mt -f /dev/nst0 asf 0 && echo "tape Right spooled to pos 0" 
if [ $? -ne 0  ]; then
    apprise --tag crit -b "second write failed" -t tapeChecks --config /mnt/app2/home/tapeManagementScripts/apprise.conf
    echo "second write failed"
    exit 1
fi
echo "second write successfull"
echo "deleting files"
rm firstStart $partName && echo "files deleted"
apprise -b "wrote $partName" -t tapeStatus --config /mnt/app2/home/tapeManagementScripts/apprise.conf
echo "----------------------------------"
echo "----------------------------------"
echo "----------------------------------"
/bin/bash /mnt/app2/home/tapeManagementScripts/autoLoaderNext.sh
echo "----------------------------------"
echo "----------------------------------"
echo "----------------------------------"
/bin/bash /mnt/app2/home/tapeManagementScripts/writePartsAutoloader.sh

    
