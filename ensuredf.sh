#!/bin/sh

[ $# -eq 2 ] || { printf '%s\n' "usage: $0 path requirement" >&2 ; exit 1;}

pth="$1"
rqrmnt="$2"
intrvl=1

</proc/$$/fd/0 cat >/proc/$$/fd/1 &
kill -s STOP $!

while [ -d /proc/$! ] ; do
  if [ $(df -P -B "$rqrmnt" "$pth" | tail -n 1 | column -t | cut -d " " -f 7) -ge 2 ]
  then kill -s CONT $!
  else kill -s STOP $!
  fi
  sleep "$intrvl"
done