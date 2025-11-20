#!/bin/bash

# Define the cron job to add (with flock)
cron_job="*/2 * * * * flock -n /tmp/update_elasticsearch_index.lock /bin/bash -l -c 'cd /var/www/mlab_api && ./bin/update_elasticsearch_index.sh --silent >> log/elasticsearch.log 2>&1'"

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


# Define the second cron job (with flock)
cron_job2="*/5 * * * * flock -n /tmp/nlims_sync.lock /bin/bash -l -c 'cd /var/www/mlab_api && ./bin/nlims_sync.sh --silent >> log/nlims_sync.log 2>&1'"

# Remove old cron job if present
cron_job_to_remove="*/2 * * * * /bin/bash -l -c 'cd /var/www/mlab_api && ./bin/nlims_sync.sh --silent >> log/nlims_sync.log 2>&1'"
(crontab -l | grep -vF "$cron_job_to_remove") | crontab -

# Get current cron jobs
current_cron_jobs2=$(crontab -l 2>/dev/null)

# Check if the cron job with flock already exists
if echo "$current_cron_jobs2" | grep -F "$cron_job2" >/dev/null; then
    echo "Cron job already exists."
else
    # Append it if it doesn't exist
    echo -e "$current_cron_jobs2\n$cron_job2" | crontab -
    echo "Cron job added successfully!"
fi
