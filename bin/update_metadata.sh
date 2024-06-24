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

# Only update metadata if migration is successful
rails db:migrate && {
    # Clear existing home dashboard data
    rails r iblis_migration/update_home_dashboard.rb && {
        # Add client identifier types
        rails r iblis_migration/client_identifier_type.rb
    }
}
