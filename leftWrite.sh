#!/bin/bash
echo $1
sleep 5
mbuffer -P 86 -m 7G -o /dev/nst0 -s 524288 -i $1 &&  mt -f /dev/nst0 weof 1 && sudo mt -f /dev/nst0 asf 0 && echo "tape left spooled to pos 0" && mbuffer -P 86 -m 7G -i /dev/nst0 -s 524288 | sha1sum > $1.sha1.R && mt -f /dev/nst0 eject
shaFromTape=$(cat $1.sha1.R | cut -d " " -f 1)
shaFromFile=$(cat $1.sha1 | cut -d " " -f 1)

if [ "$shaFromTape" = "$shaFromFile" ]; then
    echo "Checksums Match!"
    echo "write and read from Tape successfull"
else
    echo "Checksum check FAILED!"
    echo "sha from tape: "
    echo $shaFromTape
    echo "sha from File:"
    echo $shaFromFile
fi
