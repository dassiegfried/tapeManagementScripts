#!/bin/sh
cd /home/truenas_admin/tapeManagementScripts
sudo sg_read_attr /dev/nst0 && /bin/bash ./autoloaderReadWriteTest.sh && sudo /mnt/app2/home/tapeManagementScripts/ITDT/itdt -f /dev/sg0 devicestatistics &&  sudo mt -f /dev/nst0 load && echo "load success" && echo "start spooling" && sudo mt -f /dev/nst0 asf 0 && echo "tape spooled to pos 0" && sudo sg_read_attr /dev/nst0
if [ $? -ne 0 ]; then
    apprise  --tag crit -b "tape check failed" -t tapeChecks --config ./apprise.conf
    echo "something is wrong with this tape." > /dev/tty
    echo "please manually replace this tape with a working tape" > /dev/tty
    echo "you have TWO more tape tries before we will resume writing to the inserted tape no matter the test results" > /dev/tty
    echo "Press ENTER to test new Tape" > /dev/tty
    read < /dev/tty
    sudo sg_read_attr /dev/nst0 && /bin/bash ./autoloaderReadWriteTest.sh && sudo /mnt/app2/home/tapeManagementScripts/ITDT/itdt -f /dev/sg0 devicestatistics &&  sudo mt -f /dev/nst0 load && echo "load success" && echo "start spooling" && sudo mt -f /dev/nst0 asf 0 && echo "tape spooled to pos 0" && sudo sg_read_attr /dev/nst0
    if [ $? -ne 0 ]; then
        apprise --tag crit -b "tape check failed" -t tapeChecks --config ./apprise.conf
        echo "something is wrong with this tape." > /dev/tty
        echo "please manually replace this tape with a working tape" > /dev/tty
        echo "you have ONE more tape tries before we will resume writing to the inserted tape no matter the test results" > /dev/tty
        echo "Press ENTER to test new Tape" > /dev/tty
        read < /dev/tty
        sudo sg_read_attr /dev/nst0 && /bin/bash ./autoloaderReadWriteTest.sh && sudo /mnt/app2/home/tapeManagementScripts/ITDT/itdt -f /dev/sg0 devicestatistics &&  sudo mt -f /dev/nst0 load && echo "load success" && echo "start spooling" && sudo mt -f /dev/nst0 asf 0 && echo "tape spooled to pos 0" && sudo sg_read_attr /dev/nst0
        if [ $? -ne 0 ]; then
            apprise --tag crit -b "tape check failed" -t tapeChecks --config ./apprise.conf
            echo "something is wrong with this tape." > /dev/tty
            echo "please manually replace this tape with a working tape" > /dev/tty
            echo "you have ONE more tape tries before we will resume writing to the inserted tape no matter the test results" > /dev/tty
            echo "Press ENTER to test new Tape" > /dev/tty
            read < /dev/tty
        fi
    fi

fi
