#!/bin/bash
echo $1
set -a && source .env && set +a
shaRemote=$(cat $1.sha1.remote | cut -d " " -f 1)
shaFromFile=$(cat $1.sha1 | cut -d " " -f 1)
if ./tapeChecksRight.sh ; then
  if [ "$shaRemote" = "$shaFromFile" ]; then
    echo "local and remote check success"
    echo "sleeping 200sek to ensure other tape write finishes before this one because we delete after and they dont"
    sleep 400
    mbuffer -P 86 -m 7G -o /dev/nst1 -s 524288 -i $1 &&  mt -f /dev/nst1 weof 1 && sudo mt -f /dev/nst1 asf 0 && echo "tape Right spooled to pos 0" && mbuffer -P 86 -m 7G -i /dev/nst1 -s 524288 | sha1sum > $1.sha1.R && mt -f /dev/nst1 eject
    # && rm $1
    shaFromTape=$(cat $1.sha1.L | cut -d " " -f 1)
    shaFromTapeRight=$(cat $1.sha1.R | cut -d " " -f 1)

    if [ "$shaFromTape" = "$shaFromFile" ]; then
        echo "Checksums Left Match to File"
        echo "write and read from Tape successfull"
        if [ "$shaFromTapeRight" = "$shaFromFile" ]; then
         echo "Checksums Right match to File"
         if [ "$shaFromTapeRight" = "$shaRemote" ]; then
          echo "Checksums Right match to Remote"
          echo "all checksums match"
          echo "delete File"
          rm $1
          apprise -b "All tapes written & checksums match" -t tapeFinsih $notify
         else
          echo "checksum check FAILED! Right Tape Checksum dont match remote"
          apprise -b "checksum check FAILED! Right Tape Checksum dont match remote" -t tapeRightFail $notify
         fi
        else
         echo "checksum check FAILED! Right Tape Checksum dont match File"
         apprise -b "checksum check FAILED! Right Tape Checksum dont match File" -t tapeRightFail $notify
        fi
    else
        echo "Checksum check FAILED!"
        echo "sha from tape: "
        echo $shaFromTape
        echo "sha from File:"
        echo $shaFromFile
        apprise -b "tape right checksum missmatch" -t tapeRightFail $notify
    fi
  else
    echo "FAIL!! Remote and local file Checksums do not match!"
    apprise -b "local and remote checksums dont match" -t tapeFail $notify
  fi
else
 apprise -b "tape check right failed" -t tapeRightFail $notify
fi
