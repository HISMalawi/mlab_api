#!/bin/bash

# Set default environment
DEFAULT_ENVIRONMENT="production"
echo "Type the environment e.g development (default is $DEFAULT_ENVIRONMENT, press Enter to use default):"
read environment

# Set environment to default if empty
if [ -z "$environment" ]; then
    echo "Using default environment $DEFAULT_ENVIRONMENT"
    environment="$DEFAULT_ENVIRONMENT"
else
    if [ "$environment" = "development" ]; then
        echo "You are running in development environment."
    else
        if [ "$environment" != "development" ] && [ "$environment" != "production" ]; then
            echo "Invalid environment, environment should either be production or development. Exiting..."
            exit 1
        fi
    fi
fi


echo "=====iBLIS -> MLAB Data Migration===="
echo "1. Initialize migration"
echo "2. Migrate users data"
echo "3. Migrate clients"
echo "4. Migrate meta data"
echo "5. Migrate instruments"
echo "6. Migrate encounter types"
echo "7. Migrate facility data"
echo "8. Migrate encounters"
echo "9. Migrate orders"
echo "10. Migrate tests"
echo "11. Migrate tests results"
echo "12. Migrate culture Observations"
echo "13. Migrate drug susceptiblities"
echo "14. Migrate order print trail"
echo "Enter the steps you want to run (1-12), separated by spaces, or press Enter key to run all steps:"
read steps

echo "==== starting migrations ===="
if [ -z "$steps" ]; then
    # Run all steps if no input is provided
    for script in iblis_migration/iblis/init_migration.rb iblis_migration/iblis/load_users_data.rb iblis_migration/iblis/load_clients.rb iblis_migration/iblis/meta_data.rb iblis_migration/iblis/migrate_intruments.rb iblis_migration/iblis/load_encounter_types.rb iblis_migration/iblis/load_facility_data.rb iblis_migration/iblis/load_encounter.rb iblis_migration/iblis/load_orders.rb iblis_migration/iblis/load_test.rb iblis_migration/iblis/load_test_results.rb iblis_migration/iblis/culture_observations.rb iblis_migration/iblis/drug_susceptibilities.rb iblis_migration/iblis/load_order_print_trail.rb; do
        RAILS_ENV=$environment rails r $script
    done
else
    # Run selected steps based on user input
    for step in $steps; do
        case $step in
            1) RAILS_ENV=$environment rails r iblis_migration/iblis/init_migration.rb ;;
            2) RAILS_ENV=$environment rails r iblis_migration/iblis/load_users_data.rb ;;
            3) RAILS_ENV=$environment rails r iblis_migration/iblis/load_clients.rb ;;
            4) RAILS_ENV=$environment rails r iblis_migration/iblis/meta_data.rb ;;
            5) RAILS_ENV=$environment rails r iblis_migration/iblis/migrate_intruments.rb ;;
            6) RAILS_ENV=$environment rails r iblis_migration/iblis/load_encounter_types.rb ;;
            7) RAILS_ENV=$environment rails r iblis_migration/iblis/load_facility_data.rb ;;
            8) RAILS_ENV=$environment rails r iblis_migration/iblis/load_encounter.rb ;;
            9) RAILS_ENV=$environment rails r iblis_migration/iblis/load_orders.rb ;;
            10) RAILS_ENV=$environment rails r iblis_migration/iblis/load_test.rb ;;
            11) RAILS_ENV=$environment rails r iblis_migration/iblis/load_test_results.rb ;;
            12) RAILS_ENV=$environment rails r iblis_migration/iblis/culture_observations.rb ;;
            13) RAILS_ENV=$environment rails r iblis_migration/iblis/drug_susceptibilities.rb ;;
            14) RAILS_ENV=$environment rails r iblis_migration/iblis/load_order_print_trail.rb ;;
            *) echo "Invalid step number: $step" ;;
        esac
    done
fi
RAILS_ENV=$environment rails r iblis_migration/update_user_location.rb &&
RAILS_ENV=$environment rails r iblis_migration/update_test_lab_location.rb
