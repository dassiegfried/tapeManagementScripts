#!/bin/sh
sudo sg_read_attr /dev/nst1 && sudo /home/mike/ITDT/itdt -f /dev/sg1 standardtest -forcedataoverwrite && sudo /home/mike/ITDT/itdt -f /dev/sg1 devicestatistics &&  sudo mt -f /dev/nst1 load && echo "load success" && sudo mt -f /dev/nst1 asf 0 && echo "tape spooled to pos 0" && sudo sg_read_attr /dev/nst1
