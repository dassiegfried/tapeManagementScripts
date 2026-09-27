#!/bin/bash
cd /mnt/app2/home
for var in "$@"
do
    # if file.md5 exists a proccess is already hashing and we dont need to start another one
    if [ -f $var.md5 ]; then
        continue
    else
        #no proccess is currently hashing this file so we are the one to start calculation on the hash
        fileSizeInBytes=$(stat --printf="%s" $var)

        if [ $fileSizeInBytes -lt 760000000000 ]; then
            continue
        fi
        md5sum $var > $var.md5
    fi
done
