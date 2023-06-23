#!bin/bash
rails r bin/iblis/init_migration.rb &&
rails r bin/iblis/load_users_data.rb &&
rails r bin/iblis/load_clients.rb &&
rails r bin/iblis/meta_data.rb &&
rails r bin/iblis/migrate_intruments.rb
rails r bin/iblis/load_encounter_types.rb &&
rails r bin/iblis/load_facility_data.rb &&
rails r bin/iblis/load_encounter.rb &&
rails r bin/iblis/load_orders.rb &&
rails r bin/iblis/load_test.rb &&
rails r bin/iblis/load_test_results.rb &&
rails r bin/iblis/load_order_print_trail.rb
