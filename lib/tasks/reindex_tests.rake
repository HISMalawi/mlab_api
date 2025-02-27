# frozen_string_literal: true

# reindex_tests task
# lib/tasks/reindex_tests.rake
namespace :db do
  desc 'Rerun indexes on tests table for test_type_id, lab_location_id, and status_id'
  task reindex_tests: :environment do
    puts 'Starting to reindex tests table...'

    # Remove indexes if they exist
    if ActiveRecord::Base.connection.index_exists?(:tests, %i[test_type_id lab_location_id])
      puts 'Removing index on test_type_id and lab_location_id...'
      ActiveRecord::Base.connection.remove_index(:tests, %i[test_type_id lab_location_id])
    end

    if ActiveRecord::Base.connection.index_exists?(:tests, %i[status_id lab_location_id])
      puts 'Removing index on status_id and lab_location_id...'
      ActiveRecord::Base.connection.remove_index(:tests, %i[status_id lab_location_id])

    end

    if ActiveRecord::Base.connection.index_exists?(:tests, %i[status_id lab_location_id test_type_id])
      puts 'Removing index on status_id, lab_location_id, and test_type_id...'
      ActiveRecord::Base.connection.remove_index(:tests, %i[status_id lab_location_id test_type_id])
    end

    if ActiveRecord::Base.connection.index_exists?(:tests, %i[status_id lab_location_id voided])
      puts 'Removing index on status_id, lab_location_id, and voided...'
      ActiveRecord::Base.connection.remove_index(:tests, %i[status_id lab_location_id voided])
    end
    # Add indexes
    puts 'Adding index on test_type_id and lab_location_id...'
    ActiveRecord::Base.connection.add_index(:tests, %i[test_type_id lab_location_id])

    puts 'Adding index on status_id and lab_location_id...'
    ActiveRecord::Base.connection.add_index(:tests, %i[status_id lab_location_id])

    puts 'Adding index on status_id, lab_location_id, and test_type_id...'
    ActiveRecord::Base.connection.add_index(:tests, %i[status_id lab_location_id test_type_id])

    puts 'Adding index on status_id, lab_location_id, and voided...'
    ActiveRecord::Base.connection.add_index(:tests, %i[status_id lab_location_id voided])

    puts 'Reindexing completed successfully!'
  end
end
