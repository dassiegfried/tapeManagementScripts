#!/bin/bash
echo $1
#echo "sleeping 200sek to ensure other tape write finishes before this one because we delete after and they dont"
#sleep 200
mbuffer -P 86 -m 14G -o /dev/nst0 -o /dev/nst1 -s 8388608 -i $1 &&  mt -f /dev/nst0 weof 1 && mt -f /dev/nst0 eject &&  mt -f /dev/nst1 weof 1 && mt -f /dev/ns1 eject && rm $1
