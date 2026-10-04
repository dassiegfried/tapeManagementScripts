#!/bin/bash
#!/bin/bash
if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi
cd /mnt/app2/home
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
    apprise --tag crit -b "tartgeted file $partName dosnt exists!" -t missingFile --config ./apprise.conf
fi
until [ -f $partName.md5 ]
do
    sleep 5
done
echo "hash file exists we can start the write"
mbuffer -i $partName -H -P 95 -m 2G -s 524288 -o /dev/nst0 --tapeaware -A "/mnt/app2/home/tapeManagementScripts/noNextTape.sh" && mt -f /dev/nst0 weof 1 && sudo mt -f /dev/nst0 asf 0 && echo "tape Right spooled to pos 0" && mbuffer -P 86 -m 2G -i /dev/nst0 -s 524288 | md5sum > "$partName".md5.R
md5FromFile=$(cat "$partName".md5 | cut -d " " -f 1)
shaFromTape=$(cat "$partName".md5.R | cut -d " " -f 1)
if [ "$md5FromFile" = "$shaFromTape" ]; then
    echo "Checksums Match to File"
    echo "from file:"
    cat $partName.md5
    echo "from tape: "
    cat $partName.md5.R 
    echo "loading second copy tape"
    /bin/bash /mnt/app2/home/tapeManagementScripts/autoLoaderNext.sh
    mbuffer -i $partName -H -P 95 -m 2G -s 524288 -o /dev/nst0 --tapeaware -A "/mnt/app2/home/tapeManagementScripts/noNextTape.sh" &&  mt -f /dev/nst0 weof 1 && sudo mt -f /dev/nst0 asf 0 && echo "tape Right spooled to pos 0" && mbuffer -P 86 -m 2G -i /dev/nst0 -s 524288 | md5sum > "$partName".md5.L
    shaFromTapeTwo=$(cat "$partName".md5.L | cut -d " " -f 1)
    if [ "$md5FromFile" = "$shaFromTapeTwo" ]; then
        echo "Checksums Match to File"
        echo "from file:"
        cat $partName.md5
        echo "from tape: "
        cat $partName.md5.L 
        echo "deleting files"
        rm $partName $partName.md5 $partName.md5.R $partName.md5.L && echo "files deleted"
        apprise -b "wrote $partName" -t tapeStatus --config ./apprise.conf
        echo "----------------------------------"
        echo "----------------------------------"
        echo "----------------------------------"
        /bin/bash /mnt/app2/home/tapeManagementScripts/autoLoaderNext.sh
        echo "----------------------------------"
        echo "----------------------------------"
        echo "----------------------------------"
        /bin/bash /mnt/app2/home/tapeManagementScripts/writePartsAutoloader.sh
    else
        apprise --tag crit -b "md5 missmatch" -t tapeChecks --config ./apprise.conf
        echo "hashes dont match"
        echo "from file:"
        cat $partName.md5
        echo "from tape: "
        cat $partName.md5.L 
    fi
else
    apprise --tag crit -b "md5 missmatch" -t tapeChecks --config ./apprise.conf
    echo "hashes dont match"
    echo "from file:"
    cat $partName.md5
    echo "from tape: "
    cat $partName.md5.R 
fi

    
