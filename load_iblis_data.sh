#!/bin/bash

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
    RAILS_ENV=production rails r iblis_migration/iblis/init_migration.rb &&
    RAILS_ENV=production rails r iblis_migration/iblis/load_users_data.rb &&
    RAILS_ENV=production rails r iblis_migration/iblis/load_clients.rb &&
    RAILS_ENV=production rails r iblis_migration/iblis/meta_data.rb &&
    RAILS_ENV=production rails r iblis_migration/iblis/migrate_intruments.rb &&
    RAILS_ENV=production rails r iblis_migration/iblis/load_encounter_types.rb &&
    RAILS_ENV=production rails r iblis_migration/iblis/load_facility_data.rb &&
    RAILS_ENV=production rails r iblis_migration/iblis/load_encounter.rb &&
    RAILS_ENV=production rails r iblis_migration/iblis/load_orders.rb &&
    RAILS_ENV=production rails r iblis_migration/iblis/load_test.rb &&
    RAILS_ENV=production rails r iblis_migration/iblis/load_test_results.rb &&
    RAILS_ENV=production rails r iblis_migration/iblis/culture_observations.rb &&
    RAILS_ENV=production rails r iblis_migration/iblis/drug_susceptibilities.rb &&
    RAILS_ENV=production rails r iblis_migration/iblis/load_order_print_trail.rb
else
    # Run selected steps based on user input
    for step in $steps; do
        case $step in
            1) RAILS_ENV=production rails r iblis_migration/iblis/init_migration.rb ;;
            2) RAILS_ENV=production rails r iblis_migration/iblis/load_users_data.rb ;;
            3) RAILS_ENV=production rails r iblis_migration/iblis/load_clients.rb ;;
            4) RAILS_ENV=production rails r iblis_migration/iblis/meta_data.rb ;;
            5) RAILS_ENV=production rails r iblis_migration/iblis/migrate_intruments.rb ;;
            6) RAILS_ENV=production rails r iblis_migration/iblis/load_encounter_types.rb ;;
            7) RAILS_ENV=production rails r iblis_migration/iblis/load_facility_data.rb ;;
            8) RAILS_ENV=production rails r iblis_migration/iblis/load_encounter.rb ;;
            9) RAILS_ENV=production rails r iblis_migration/iblis/load_orders.rb ;;
            10) RAILS_ENV=production rails r iblis_migration/iblis/load_test.rb ;;
            11) RAILS_ENV=production rails r iblis_migration/iblis/load_test_results.rb ;;
            12) RAILS_ENV=production rails r iblis_migration/iblis/culture_observations.rb ;;
            13) RAILS_ENV=production rails r iblis_migration/iblis/drug_susceptibilities.rb;;
            14) RAILS_ENV=production rails r iblis_migration/iblis/load_order_print_trail.rb ;;
            *) echo "Invalid step number: $step" ;;
        esac
    done
fi
