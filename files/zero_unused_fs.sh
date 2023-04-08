#!/bin/bash
echo "------- Start zeroing at $(date)-------"
dd if=/dev/zero of=/home/pi/delete_me
echo "------- Done  zeroing at $(date)-------"
sync
sync
echo "------- Delete dummy file -------"
rm -f /home/pi/delete_me
sync
sync
echo "-------Finish zeroing at $(date)-------"