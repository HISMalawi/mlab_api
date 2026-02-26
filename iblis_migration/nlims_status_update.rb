# frozen_string_literal: true

# Lock file path (using /tmp for consistency with other cron jobs)
LOCK_FILE = '/tmp/nlims_status_update.lock'

# Check if another instance is already running
if File.exist?(LOCK_FILE)
  pid = File.read(LOCK_FILE).strip.to_i
  begin
    # Check if the process is still running
    Process.getpgid(pid)
    puts "Another instance is already running (PID: #{pid}). Exiting."
    Rails.logger.warn("nlims_status_update: Another instance already running (PID: #{pid})")
    exit 0
  rescue Errno::ESRCH
    # Process not found, stale lock file
    puts "Removing stale lock file (PID: #{pid} not found)"
    File.delete(LOCK_FILE)
  end
end

# Create lock file with current process ID
File.write(LOCK_FILE, Process.pid)
puts "Lock acquired (PID: #{Process.pid})"

begin
  unsynchronized_updates = UnsyncOrder.joins('INNER JOIN tests ON tests.id = unsync_orders.test_or_order_id')
                                      .joins('INNER JOIN orders ON orders.id = tests.order_id')
                                      .where(data_level: 'test', sync_status: false)
                                      .where.not(data_not_synced: 'add_test_to_order')
                                      .where('orders.created_date >= ?', '2026-02-25')

  puts "Processing #{unsynchronized_updates.count} unsynchronized updates"

  success_count = 0
  error_count = 0

  unsynchronized_updates.select(:id).find_each do |update|
    Nlims::Sync.update_test_v2(id: update.id)
    success_count += 1
  rescue SystemStackError => e
    error_count += 1
    Rails.logger.error("Stack overflow for UnsyncOrder ID #{update.id}: #{e.message}")
    puts "Skipping UnsyncOrder ID #{update.id} - stack overflow error"
  rescue StandardError => e
    error_count += 1
    Rails.logger.error("Error processing UnsyncOrder ID #{update.id}: #{e.message}")
    puts "Error processing UnsyncOrder ID #{update.id}: #{e.message}"
  end

  puts "\nProcessing complete: #{success_count} successful, #{error_count} errors"
ensure
  # Always remove lock file when done
  File.delete(LOCK_FILE) if File.exist?(LOCK_FILE)
  puts 'Lock released'
end
