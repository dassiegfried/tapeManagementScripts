#!/bin/sh
sudo sg_read_attr /dev/nst0 && sudo /home/mike/ITDT/itdt -f /dev/sg0 standardtest -forcedataoverwrite && sudo /home/mike/ITDT/itdt -f /dev/sg0 devicestatistics &&  sudo mt -f /dev/nst0 load && echo "load success" && sudo mt -f /dev/nst0 asf 0 && echo "tape spooled to pos 0" && sudo sg_read_attr /dev/nst0
