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
    rails db:seed
}
