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
    # Handle test indicators data
    rails r iblis_migration/update_test_type_test_indicator_mapping.rb && {
        # Update User location
        rails r iblis_migration/update_user_location.rb && {
            # Update test lab location
            rails r iblis_migration/update_test_lab_location.rb && {
                # Clear existing home dashboard data
                rails r iblis_migration/update_home_dashboard.rb
            }
        }
    }
}
