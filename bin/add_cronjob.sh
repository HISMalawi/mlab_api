#!/bin/bash

# Define the cron job to add
cron_job="*/2 * * * * /bin/bash -l -c 'cd /home/hopgausi/HisMalawi/mlab_api && ./bin/update_elasticsearch_index.sh --silent >> log/elasticsearch.log 2>&1'"

# Get the current list of cron jobs
current_cron_jobs=$(crontab -l 2>/dev/null)

# Check if the cron job already exists
if echo "$current_cron_jobs" | grep -F "$cron_job" >/dev/null; then
    echo "Cron job already exists."
else
    # Append the new cron job if it doesn't exist
    echo -e "$current_cron_jobs\n$cron_job" | crontab -
    echo "Cron job added successfully!"
fi
