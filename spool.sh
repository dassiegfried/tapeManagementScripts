#!/bin/bash
 sudo mt -f /dev/nst0 asf 0 && echo "tape 0 spooled to pos 0" && sudo mt -f /dev/nst1 asf 0 && echo "tape 1 spooled to pos 0"
