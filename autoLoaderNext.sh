#!/bin/bash
# mbuffer passes information via environment variables like $MBUFFER_VOL

# 1. Attempt your standard tape change command (e.g., using mtx)
# Replace this with your actual tape loading logic
cd /mnt/app2/home/tapeManagementScripts/
sudo mtx -f /dev/sg36 next 0
# 2. Check if the tape load succeeded 
if [ $? -ne 0 ]; then
    # If it failed (meaning the autoloader is empty or has a mechanical issue)
    apprise -b "autoloader tape failed check manually " -t autoloader --config ./apprise.conf
    echo "=== AUTOLOADER EMPTY OR ERROR ===" > /dev/tty
    echo "Please reload the tape magazine, then press [ENTER] to continue..." > /dev/tty
    echo "after resume we load the next tape from slot 0 make sure you have inserted new tapes!"
    # Read directly from the physical terminal device so it works even if piped
    read < /dev/tty
    
    # 3. Try loading the tape again after the user hit ENTER
    echo "loading tape from slot 1 to drive 0" > /dev/tty
    sudo mtx -f /dev/sg36 load 1 0
    
    if [ $? -ne 0 ]; then
        echo "Failed to load tape a second time. Aborting backup." > /dev/tty
        exit 1 # Hard fail if it still fails
    fi
fi
echo "starting tape checks" > /dev/tty
/bin/bash ./tapeChecks.sh
# Exit with 0 so mbuffer resumes writing to the next tape
exit 0
