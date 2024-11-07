#!/bin/bash

# Total wait time in seconds (30 minutes = 1800 seconds)
total_wait=1800

# Countdown loop
echo "-------------------------------"
echo "Script to restart redis after $((total_wait / 60)) minutes"
echo "--------------------------------"
while [ $total_wait -gt 0 ]; do
    echo "Time remaining before executing the script: $((total_wait / 60)) minutes and $((total_wait % 60)) seconds"
    sleep 1
    ((total_wait--))
done

# Run the command after the countdown
sudo systemctl restart redis-server.service
echo "Script executed successfully"