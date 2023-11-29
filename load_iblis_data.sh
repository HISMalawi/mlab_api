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
echo "12. Migrate order print trail"
echo "Enter the steps you want to run (1-12), separated by spaces, or press Enter key to run all steps:"
read steps

echo "==== starting migrations ===="
if [ -z "$steps" ]; then
    # Run all steps if no input is provided
    rails r bin/iblis/init_migration.rb &&
    rails r bin/iblis/load_users_data.rb &&
    rails r bin/iblis/load_clients.rb &&
    rails r bin/iblis/meta_data.rb &&
    rails r bin/iblis/migrate_intruments.rb &&
    rails r bin/iblis/load_encounter_types.rb &&
    rails r bin/iblis/load_facility_data.rb &&
    rails r bin/iblis/load_encounter.rb &&
    rails r bin/iblis/load_orders.rb &&
    rails r bin/iblis/load_test.rb &&
    rails r bin/iblis/load_test_results.rb &&
    rails r bin/iblis/load_order_print_trail.rb
else
    # Run selected steps based on user input
    for step in $steps; do
        case $step in
            1) rails r bin/iblis/init_migration.rb ;;
            2) rails r bin/iblis/load_users_data.rb ;;
            3) rails r bin/iblis/load_clients.rb ;;
            4) rails r bin/iblis/meta_data.rb ;;
            5) rails r bin/iblis/migrate_intruments.rb ;;
            6) rails r bin/iblis/load_encounter_types.rb ;;
            7) rails r bin/iblis/load_facility_data.rb ;;
            8) rails r bin/iblis/load_encounter.rb ;;
            9) rails r bin/iblis/load_orders.rb ;;
            10) rails r bin/iblis/load_test.rb ;;
            11) rails r bin/iblis/load_test_results.rb ;;
            12) rails r bin/iblis/load_order_print_trail.rb ;;
            *) echo "Invalid step number: $step" ;;
        esac
    done
fi
