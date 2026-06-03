# frozen_string_literal: true

BATCH_SIZE = ENV.fetch('BATCH_SIZE', 10_000).to_i
PROGRESS_MUTEX = Mutex.new

# Rake tasks to backfill UUIDs for all transactional tables
# This includes:
# - orders
# - tests
# - order_statuses
# - test_statuses
# - test_results
#
# Each task will backfill UUIDs in batches and print progress.
# The main task `uuid:backfill_all` will run all tasks in the correct order.
# Usage:
#   rake uuid:backfill_all
#   rake uuid:verify
#   rake uuid:add_indexes
#   rake uuid:add_constraints
#   rake uuid:progress
#
# # Quick status check
# ./bin/monitor_uuid.sh
#
# Real-time log monitoring
# tail -f log/uuid_backfill.log
#
# Check progress percentage
# rake uuid:progress
namespace :uuid do
  desc 'Backfill UUIDs for all transactional tables'

  task backfill_all: :environment do
    use_parallel = ENV.fetch('PARALLEL', 'true') == 'true'

    puts 'Starting UUID backfill process...'
    puts "Batch size: #{BATCH_SIZE}"
    puts "Parallel processing: #{use_parallel ? 'enabled' : 'disabled'}"
    puts '=' * 80

    # Process parent tables first (these must be sequential)
    puts "\nProcessing parent tables..."
    ENV['PARALLEL_MODE'] = 'false'
    Rake::Task['uuid:backfill_orders'].invoke
    Rake::Task['uuid:backfill_tests'].invoke

    # Process child tables (can run in parallel since they're independent)
    if use_parallel
      puts "\nProcessing child tables in parallel..."
      puts "(Progress will be shown per task)\n"

      # Reserve 3 lines for progress display
      puts '[3/5] Order Statuses: Initializing...'
      puts '[4/5] Test Statuses: Initializing...'
      puts '[5/5] Test Results: Initializing...'

      require 'parallel'

      ENV['PARALLEL_MODE'] = 'true'
      child_tasks = [
        'uuid:backfill_order_statuses',
        'uuid:backfill_test_statuses',
        'uuid:backfill_test_results'
      ]

      Parallel.each(child_tasks, in_threads: 3) do |task_name|
        # Re-establish database connection for each thread
        ActiveRecord::Base.connection_pool.with_connection do
          Rake::Task[task_name].invoke
        end
      end

      # Move cursor down past the progress lines
      puts "\n"

      ENV['PARALLEL_MODE'] = 'false'
    else
      puts "\nProcessing child tables sequentially..."
      ENV['PARALLEL_MODE'] = 'false'
      Rake::Task['uuid:backfill_order_statuses'].invoke
      Rake::Task['uuid:backfill_test_statuses'].invoke
      Rake::Task['uuid:backfill_test_results'].invoke
    end

    puts '=' * 80
    puts 'UUID backfill complete!'
    puts "\nNext steps:"
    puts '1. Verify data integrity: rake uuid:verify'
    puts '2. Add indexes: rake uuid:add_indexes'
    puts '3. Update models with Uuidable concern'
    puts '4. Add NOT NULL constraints: rake uuid:add_constraints'
  end

  desc 'Backfill UUIDs for orders table'
  task backfill_orders: :environment do
    parallel_mode = ENV['PARALLEL_MODE'] == 'true'
    task_label = 'Orders'

    puts "\n[1/5] Backfilling orders table..."

    total = Order.where(uuid: nil).count
    processed = 0

    Order.where(uuid: nil).in_batches(of: BATCH_SIZE) do |batch|
      batch.update_all("uuid = '#{UUID7.generate}'") if batch.count == 1

      # For batches, update individually to ensure unique UUIDs
      batch.find_each do |record|
        record.update_column(:uuid, UUID7.generate) if record.uuid.nil?
        processed += 1

        # Update progress every 1000 records
        if total > 0 && processed % 1000 == 0
          current_percent = (processed.to_f / total * 100).round(2)
          if parallel_mode
            PROGRESS_MUTEX.synchronize do
              puts "  [#{task_label}] Progress: #{processed}/#{total} (#{current_percent}%)"
              $stdout.flush
            end
          else
            print "\r  Progress Orders: #{processed}/#{total} (#{current_percent}%)"
            $stdout.flush
          end
        end
      end
    end

    if parallel_mode
      PROGRESS_MUTEX.synchronize { puts "  ✓ [#{task_label}] Complete. Total: #{total}" }
    else
      puts "\n  ✓ Orders complete. Total: #{total}"
    end
  end

  desc 'Backfill UUIDs for tests table and copy order UUIDs'
  task backfill_tests: :environment do
    parallel_mode = ENV['PARALLEL_MODE'] == 'true'
    task_label = 'Tests'

    puts "\n[2/5] Backfilling tests table..."

    total = Test.where(uuid: nil).count
    processed = 0

    Test.where(uuid: nil).includes(:order).in_batches(of: BATCH_SIZE) do |batch|
      batch.find_each do |test|
        if test.uuid.nil?
          test.update_columns(
            uuid: UUID7.generate,
            order_uuid: test.order&.uuid
          )
          processed += 1

          # Update progress every 1000 records
          if total > 0 && processed % 1000 == 0
            current_percent = (processed.to_f / total * 100).round(2)
            if parallel_mode
              PROGRESS_MUTEX.synchronize do
                puts "  [#{task_label}] Progress: #{processed}/#{total} (#{current_percent}%)"
                $stdout.flush
              end
            else
              print "\r  Progress Tests: #{processed}/#{total} (#{current_percent}%)"
              $stdout.flush
            end
          end
        end
      end
    end

    if parallel_mode
      PROGRESS_MUTEX.synchronize { puts "  ✓ [#{task_label}] Complete. Total: #{total}" }
    else
      puts "\n  ✓ Tests complete. Total: #{total}"
    end
  end

  desc 'Backfill UUIDs for order_statuses table and copy order UUIDs'
  task backfill_order_statuses: :environment do
    parallel_mode = ENV['PARALLEL_MODE'] == 'true'
    line_offset = 3 # Line 1 of 3 in parallel display

    total = OrderStatus.where(uuid: nil).count
    processed = 0

    OrderStatus.where(uuid: nil).includes(:order).in_batches(of: BATCH_SIZE) do |batch|
      batch.find_each do |order_status|
        if order_status.uuid.nil?
          order_status.update_columns(
            uuid: UUID7.generate,
            order_uuid: order_status.order&.uuid
          )
          processed += 1

          # Update progress every 1000 records
          if total > 0 && processed % 1000 == 0
            current_percent = (processed.to_f / total * 100).round(2)
            if parallel_mode
              PROGRESS_MUTEX.synchronize do
                # Move cursor up, clear line, print update, move cursor back down
                print "\e[#{line_offset}A\r\e[2K[3/5] Order Statuses: #{processed}/#{total} (#{current_percent}%)\e[#{line_offset}B\r"
                $stdout.flush
              end
            else
              print "\r  Progress Order Statuses: #{processed}/#{total} (#{current_percent}%)"
              $stdout.flush
            end
          end
        end
      end
    end

    if parallel_mode
      PROGRESS_MUTEX.synchronize do
        print "\e[#{line_offset}A\r\e[2K[3/5] Order Statuses: ✓ Complete (#{total} records)\e[#{line_offset}B\r"
        $stdout.flush
      end
    else
      puts "\n  ✓ Order statuses complete. Total: #{total}"
    end
  end

  desc 'Backfill UUIDs for test_statuses table and copy test UUIDs'
  task backfill_test_statuses: :environment do
    parallel_mode = ENV['PARALLEL_MODE'] == 'true'
    line_offset = 2 # Line 2 of 3 in parallel display

    total = TestStatus.where(uuid: nil).count
    processed = 0

    TestStatus.where(uuid: nil).includes(:test).in_batches(of: BATCH_SIZE) do |batch|
      batch.find_each do |test_status|
        if test_status.uuid.nil?
          test_status.update_columns(
            uuid: UUID7.generate,
            test_uuid: test_status.test&.uuid
          )
          processed += 1

          # Update progress every 1000 records
          if total > 0 && processed % 1000 == 0
            current_percent = (processed.to_f / total * 100).round(2)
            if parallel_mode
              PROGRESS_MUTEX.synchronize do
                # Move cursor up, clear line, print update, move cursor back down
                print "\e[#{line_offset}A\r\e[2K[4/5] Test Statuses: #{processed}/#{total} (#{current_percent}%)\e[#{line_offset}B\r"
                $stdout.flush
              end
            else
              print "\r  Progress Test Statuses: #{processed}/#{total} (#{current_percent}%)"
              $stdout.flush
            end
          end
        end
      end
    end

    if parallel_mode
      PROGRESS_MUTEX.synchronize do
        print "\e[#{line_offset}A\r\e[2K[4/5] Test Statuses: ✓ Complete (#{total} records)\e[#{line_offset}B\r"
        $stdout.flush
      end
    else
      puts "\n  ✓ Test statuses complete. Total: #{total}"
    end
  end

  desc 'Backfill UUIDs for test_results table and copy test UUIDs'
  task backfill_test_results: :environment do
    parallel_mode = ENV['PARALLEL_MODE'] == 'true'
    line_offset = 1 # Line 3 of 3 in parallel display

    total = TestResult.where(uuid: nil).count
    processed = 0

    TestResult.where(uuid: nil).includes(:test).in_batches(of: BATCH_SIZE) do |batch|
      batch.find_each do |test_result|
        if test_result.uuid.nil?
          test_result.update_columns(
            uuid: UUID7.generate,
            test_uuid: test_result.test&.uuid
          )
          processed += 1

          # Update progress every 1000 records
          if total > 0 && processed % 1000 == 0
            current_percent = (processed.to_f / total * 100).round(2)
            if parallel_mode
              PROGRESS_MUTEX.synchronize do
                # Move cursor up, clear line, print update, move cursor back down
                print "\e[#{line_offset}A\r\e[2K[5/5] Test Results: #{processed}/#{total} (#{current_percent}%)\e[#{line_offset}B\r"
                $stdout.flush
              end
            else
              print "\r  Progress Test Results: #{processed}/#{total} (#{current_percent}%)"
              $stdout.flush
            end
          end
        end
      end
    end

    if parallel_mode
      PROGRESS_MUTEX.synchronize do
        print "\e[#{line_offset}A\r\e[2K[5/5] Test Results: ✓ Complete (#{total} records)\e[#{line_offset}B\r"
        $stdout.flush
      end
    else
      puts "\n  ✓ Test results complete. Total: #{total}"
    end
  end

  desc 'Verify UUID backfill integrity'
  task verify: :environment do
    puts "\nVerifying UUID backfill..."
    puts '=' * 80

    tables = {
      'orders' => Order,
      'tests' => Test,
      'order_statuses' => OrderStatus,
      'test_statuses' => TestStatus,
      'test_results' => TestResult
    }

    all_valid = true

    tables.each do |name, model|
      total = model.count
      with_uuid = model.where.not(uuid: nil).count
      null_count = total - with_uuid
      duplicates = model.group(:uuid).having('COUNT(*) > 1').count.size

      puts "\n#{name.capitalize}:"
      puts "  Total records: #{total}"
      puts "  With UUID: #{with_uuid}"
      puts "  NULL UUIDs: #{null_count}"
      puts "  Duplicate UUIDs: #{duplicates}"

      if null_count > 0
        puts '  ❌ WARNING: Found NULL UUIDs'
        all_valid = false
      end

      if duplicates > 0
        puts '  ❌ ERROR: Found duplicate UUIDs'
        all_valid = false
      end

      puts '  ✓ OK' if null_count == 0 && duplicates == 0
    end

    # Verify foreign key relationships
    puts "\nVerifying foreign key relationships..."

    # Tests -> Orders
    orphaned_tests = Test.joins(:order).where.not(order_uuid: Order.arel_table[:uuid]).count
    puts "  Tests with mismatched order_uuid: #{orphaned_tests}"
    all_valid = false if orphaned_tests > 0

    # OrderStatuses -> Orders
    orphaned_order_statuses = OrderStatus.joins(:order).where.not(order_uuid: Order.arel_table[:uuid]).count
    puts "  Order statuses with mismatched order_uuid: #{orphaned_order_statuses}"
    all_valid = false if orphaned_order_statuses > 0

    # TestStatuses -> Tests
    orphaned_test_statuses = TestStatus.joins(:test).where.not(test_uuid: Test.arel_table[:uuid]).count
    puts "  Test statuses with mismatched test_uuid: #{orphaned_test_statuses}"
    all_valid = false if orphaned_test_statuses > 0

    # TestResults -> Tests
    orphaned_test_results = TestResult.joins(:test).where.not(test_uuid: Test.arel_table[:uuid]).count
    puts "  Test results with mismatched test_uuid: #{orphaned_test_results}"
    all_valid = false if orphaned_test_results > 0

    puts "\n" + '=' * 80
    if all_valid
      puts '✓ All validations passed!'
    else
      puts '❌ Validation failed. Please review warnings above.'
    end
  end

  desc 'Show progress of UUID backfill'
  task progress: :environment do
    tables = {
      'Orders' => Order,
      'Tests' => Test,
      'Order Statuses' => OrderStatus,
      'Test Statuses' => TestStatus,
      'Test Results' => TestResult
    }

    puts "\nUUID Backfill Progress"
    puts '=' * 80
    printf "%-20s %12s %12s %12s %8s\n", 'Table', 'Total', 'With UUID', 'Remaining', 'Progress'
    puts '-' * 80

    tables.each do |name, model|
      total = model.count
      with_uuid = model.where.not(uuid: nil).count
      remaining = total - with_uuid
      progress = total > 0 ? (with_uuid.to_f / total * 100).round(2) : 0

      printf "%-20s %12d %12d %12d %7.2f%%\n", name, total, with_uuid, remaining, progress
    end

    puts '=' * 80
  end

  desc 'Add UUID indexes to all tables'
  task add_indexes: :environment do
    puts "\nAdding UUID indexes..."
    puts '=' * 80
    puts 'This will add indexes using ALGORITHM=INPLACE (online DDL)'
    puts 'Estimated time: 10-30 minutes per 10M records'
    puts '=' * 80

    connection = ActiveRecord::Base.connection

    # Define indexes to add
    indexes = [
      # Primary UUID indexes (unique)
      { table: :orders, column: :uuid, unique: true },
      { table: :tests, column: :uuid, unique: true },
      { table: :order_statuses, column: :uuid, unique: true },
      { table: :test_statuses, column: :uuid, unique: true },
      { table: :test_results, column: :uuid, unique: true },

      # Foreign key UUID indexes (non-unique)
      { table: :tests, column: :order_uuid, unique: false },
      { table: :order_statuses, column: :order_uuid, unique: false },
      { table: :test_statuses, column: :test_uuid, unique: false },
      { table: :test_results, column: :test_uuid, unique: false }
    ]

    indexes.each do |index_def|
      table = index_def[:table]
      column = index_def[:column]
      unique = index_def[:unique]

      index_name = "index_#{table}_on_#{column}"

      # Check if index already exists
      if connection.index_exists?(table, column, name: index_name)
        puts "  ⏭️  Index #{index_name} already exists, skipping..."
        next
      end

      print "  Adding index on #{table}.#{column}#{unique ? ' (unique)' : ''}... "
      start_time = Time.now

      begin
        # Use raw SQL to specify ALGORITHM=INPLACE
        unique_clause = unique ? 'UNIQUE' : ''
        connection.execute(
          "CREATE #{unique_clause} INDEX #{index_name} ON #{table} (#{column}) ALGORITHM=INPLACE"
        )

        elapsed = (Time.now - start_time).round(2)
        puts "✓ (#{elapsed}s)"
      rescue StandardError => e
        puts "❌ Error: #{e.message}"
      end
    end

    puts "\n" + '=' * 80
    puts '✓ Index creation complete!'
    puts "\nNext steps:"
    puts '1. Update models with Uuidable concern (see MODEL_UPDATE_EXAMPLES.md)'
    puts '2. Test UUID generation in console'
    puts '3. Add NOT NULL constraints: rake uuid:add_constraints'
  end

  desc 'Add NOT NULL constraints to UUID columns'
  task add_constraints: :environment do
    puts "\nAdding NOT NULL constraints to UUID columns..."
    puts '=' * 80
    puts '⚠️  This will fail if any NULL UUIDs exist'
    puts '=' * 80

    # First, verify no NULL UUIDs exist
    tables = %w[orders tests order_statuses test_statuses test_results]
    has_nulls = false

    puts "\nChecking for NULL UUIDs..."
    tables.each do |table|
      null_count = ActiveRecord::Base.connection.select_value(
        "SELECT COUNT(*) FROM #{table} WHERE uuid IS NULL"
      )

      if null_count > 0
        puts "  ❌ #{table}: #{null_count} NULL UUIDs found"
        has_nulls = true
      else
        puts "  ✓ #{table}: No NULL UUIDs"
      end
    end

    if has_nulls
      puts "\n" + '=' * 80
      puts '❌ Cannot add NOT NULL constraints: NULL UUIDs found'
      puts 'Run: rake uuid:backfill_all'
      puts '=' * 80
      abort
    end

    # Verify models are generating UUIDs for new records
    puts "\n⚠️  Before proceeding, ensure:"
    puts '  1. All models include Uuidable concern'
    puts '  2. New records are getting UUIDs'
    puts '  3. Application is tested in staging'
    print "\nContinue? (yes/no): "
    response = $stdin.gets.chomp.downcase

    unless %w[yes y].include?(response)
      puts 'Aborted.'
      exit
    end

    puts "\nAdding NOT NULL constraints..."

    connection = ActiveRecord::Base.connection

    tables.each do |table|
      print "  #{table}... "
      begin
        connection.change_column_null table.to_sym, :uuid, false
        puts '✓'
      rescue StandardError => e
        puts "❌ Error: #{e.message}"
      end
    end

    puts "\n" + '=' * 80
    puts '✓ NOT NULL constraints added successfully!'
    puts "\nFinal verification:"
    puts 'Run: rake uuid:verify'
    puts '=' * 80
  end

  desc 'Remove NOT NULL constraints from UUID columns (rollback)'
  task remove_constraints: :environment do
    puts "\nRemoving NOT NULL constraints from UUID columns..."
    puts '=' * 80

    tables = %w[orders tests order_statuses test_statuses test_results]
    connection = ActiveRecord::Base.connection

    tables.each do |table|
      print "  #{table}... "
      begin
        connection.change_column_null table.to_sym, :uuid, true
        puts '✓'
      rescue StandardError => e
        puts "❌ Error: #{e.message}"
      end
    end

    puts "\n" + '=' * 80
    puts '✓ NOT NULL constraints removed'
  end

  desc 'Remove UUID indexes (rollback)'
  task remove_indexes: :environment do
    puts "\nRemoving UUID indexes..."
    puts '=' * 80

    connection = ActiveRecord::Base.connection

    indexes = [
      { table: :orders, column: :uuid },
      { table: :tests, column: :uuid },
      { table: :order_statuses, column: :uuid },
      { table: :test_statuses, column: :uuid },
      { table: :test_results, column: :uuid },
      { table: :tests, column: :order_uuid },
      { table: :order_statuses, column: :order_uuid },
      { table: :test_statuses, column: :test_uuid },
      { table: :test_results, column: :test_uuid }
    ]

    indexes.each do |index_def|
      table = index_def[:table]
      column = index_def[:column]
      index_name = "index_#{table}_on_#{column}"

      if connection.index_exists?(table, column, name: index_name)
        print "  Removing index on #{table}.#{column}... "
        begin
          connection.remove_index table, name: index_name
          puts '✓'
        rescue StandardError => e
          puts "❌ Error: #{e.message}"
        end
      else
        puts "  ⏭️  Index #{index_name} does not exist, skipping..."
      end
    end

    puts "\n" + '=' * 80
    puts '✓ Index removal complete'
  end
end
