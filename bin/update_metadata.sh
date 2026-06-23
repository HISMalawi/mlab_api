#!/bin/bash

usage() {
    echo "Usage: $0 ENVIRONMENT"
    echo
    echo "ENVIRONMENT should be: development|test|production"
}

ENV=$1

if [ -z "$ENV" ]; then
    usage
    exit 255
fi

set -x
export RAILS_ENV=$ENV
rails db:environment:set RAILS_ENV=$ENV

bundle install --local

# Only update metadata if migration is successful
rails db:migrate && {
    rails r iblis_migration/clear_cached_reports.rb && 
    rails r iblis_migration/client_identifier_type.rb &&
    rails r iblis_migration/update_user_location.rb &&
    rails r iblis_migration/update_test_lab_location.rb &&
    rails db:seed &&
    rails r iblis_migration/void_lab_tech_indicator.rb &&
    rails r iblis_migration/load_preferences.rb &&
    rails r iblis_migration/user_preferences_init.rb &&
    rails r iblis_migration/app_setting_init.rb &&
    bash bin/attributes_metadata.sh $ENV &&
    rails r iblis_migration/metadata/mark_synced.rb &&
    rails r iblis_migration/fix_microscopy_indicators.rb
}

# Run UUID backfill tasks in background
# Logs will be written to log/uuid_*.log files
echo "Starting UUID backfill process in background..."
nohup bash -c "
    set -e
    export RAILS_ENV=$ENV
    echo '[$(date)] Starting UUID backfill...' >> log/uuid_backfill.log
    bundle exec rake uuid:backfill_all >> log/uuid_backfill.log 2>&1 && \
    echo '[$(date)] Backfill complete. Starting index creation...' >> log/uuid_backfill.log && \
    bundle exec rake uuid:add_indexes >> log/uuid_backfill.log 2>&1 && \
    echo '[$(date)] Indexes created. Adding NOT NULL constraints...' >> log/uuid_backfill.log && \
    bundle exec rake uuid:add_constraints >> log/uuid_backfill.log 2>&1 && \
    echo '[$(date)] UUID migration complete!' >> log/uuid_backfill.log || \
    echo '[$(date)] UUID migration failed. Check log for details.' >> log/uuid_backfill.log
" > /dev/null 2>&1 &

UUID_PID=$!
echo "UUID backfill running in background (PID: $UUID_PID)"
echo "Monitor progress with: tail -f log/uuid_backfill.log"
echo "Or check progress with: bundle exec rake uuid:progress"
