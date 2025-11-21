#!/bin/bash

#############################################
#  MLAB/NLIMS CRON CLEANUP & INSTALLER (PATTERN-BASED)
#############################################

echo "============================================"
echo "  STARTING MLAB/NLIMS CRON CLEANUP & INSTALLATION"
echo "============================================"

# Backup current crontab
backup_file="$HOME/crontab_backup_$(date +%Y%m%d_%H%M%S).txt"
crontab -l 2>/dev/null > "$backup_file"
echo "Backup created: $backup_file"
echo

#############################################
#  SAFELY KILL OLD MLAB/NLIMS CRON JOBS
#############################################

echo "Stopping running MLAB/NLIMS cron jobs..."

# Only kill scripts from mlab_api, nlims_sync, nlims_data_syncroniser, iBLIS
PIDS=$(ps aux \
  | grep -E "/var/www/mlab_api|/var/www/nlims_data_syncroniser|/var/www/html/iBLIS" \
  | grep -v grep \
  | awk '{print $2}')

if [ -n "$PIDS" ]; then
  echo "Killing the following PIDs:"
  echo "$PIDS"
  kill -9 $PIDS
else
  echo "No matching cron jobs running."
fi

echo

#############################################
#  REMOVE OLD/UNWANTED CRON JOBS (PATTERN-BASED)
#############################################

patterns_to_remove=(
"/var/www/mlab_api"
"/var/www/nlims_data_syncroniser"
"/var/www/html/iBLIS"
)

echo "Removing old cron jobs based on patterns..."

current_cron="$(crontab -l 2>/dev/null)"

for pattern in "${patterns_to_remove[@]}"; do
    current_cron="$(echo "$current_cron" | grep -Fv "$pattern")"
done

# Save cleaned crontab
echo "$current_cron" | crontab -
echo "Old cron jobs removed."
echo

#############################################
#  ADD FLOCK-PROTECTED CRON JOBS
#############################################

LOCK_DIR="/tmp"

cron_elasticsearch="*/2 * * * * flock -n $LOCK_DIR/update_elasticsearch_index.lock /bin/bash -l -c 'cd /var/www/mlab_api && ./bin/update_elasticsearch_index.sh --silent >> log/elasticsearch.log 2>&1'"

cron_nlims_sync="*/5 * * * * flock -n $LOCK_DIR/nlims_sync.lock /bin/bash -l -c 'cd /var/www/mlab_api && ./bin/nlims_sync.sh --silent >> log/nlims_sync.log 2>&1'"

add_job() {
    local job="$1"
    local current_cron=$(crontab -l 2>/dev/null)

    if echo "$current_cron" | grep -F "$job" >/dev/null; then
        echo "Already exists: $job"
    else
        echo -e "$current_cron\n$job" | crontab -
        echo "Added: $job"
    fi
}

echo "Adding new cron jobs..."

add_job "$cron_elasticsearch"
add_job "$cron_nlims_sync"

echo
echo "============================================"
echo "  MLAB/NLIMS CRON INSTALLATION COMPLETE"
echo "============================================"
