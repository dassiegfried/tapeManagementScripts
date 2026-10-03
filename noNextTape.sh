#!/bin/bash
cd /mnt/app2/home/tapeManagementScripts/
apprise --tag crit -b "tape ran out of room replace tape and restart write operation" -t tapeChecks --config ./apprise.conf