# frozen_string_literal: true

# Lock file path (using /tmp for consistency with other cron jobs)
LOCK_FILE = '/tmp/nlims_status_update.lock'

# Tracking number patterns to filter orders (add more patterns as needed)
TRACKING_NUMBER_PATTERNS = ['AETC'].freeze

# Minimum order creation date to process
MIN_ORDER_DATE = '2026-03-01'

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
  # Build tracking number condition from patterns
  tracking_conditions = TRACKING_NUMBER_PATTERNS.map do |pattern|
    "orders.tracking_number LIKE '%#{pattern}%'"
  end.join(' OR ')

  # Process order updates first
  unsynced_orders = UnsyncOrder.joins('INNER JOIN orders ON orders.id = unsync_orders.test_or_order_id')
                               .where(data_level: 'order', sync_status: false)
                               .where('orders.created_date >= ?', MIN_ORDER_DATE)
                               .where(tracking_conditions)

  puts "Processing #{unsynced_orders.count} order updates"

  order_success = 0
  order_errors = 0

  unsynced_orders.select(:id).find_each do |update|
    Nlims::Sync.update_order(id: update.id)
    order_success += 1
  rescue StandardError => e
    order_errors += 1
    Rails.logger.error("Error processing update_order UnsyncOrder ID #{update.id}: #{e.message}")
    puts "Error processing update_order UnsyncOrder ID #{update.id}: #{e.message}"
  end

  puts "update_order complete: #{order_success} successful, #{order_errors} errors\n"

  # Process other test updates
  unsynchronized_updates = UnsyncOrder.joins('INNER JOIN tests ON tests.id = unsync_orders.test_or_order_id')
                                      .joins('INNER JOIN orders ON orders.id = tests.order_id')
                                      .where(data_level: 'test', sync_status: false)
                                      .where.not(data_not_synced: 'add_test_to_order')
                                      .where('orders.created_date >= ?', MIN_ORDER_DATE)
                                      .where(tracking_conditions)

  puts "Processing #{unsynchronized_updates.count} unsynchronized updates"

  success_count = 0
  error_count = 0

  unsynchronized_updates.select(:id, :test_or_order_id).find_each do |update|
    order = Order.joins(:tests).where(tests: { id: update.test_or_order_id }).first
    if order.present?
      u_order = UnsyncOrder.find_by(test_or_order_id: order.id, data_level: 'order',
                                    data_not_synced: %w[specimen-accepted specimen-rejected])
    end
    Nlims::Sync.update_order(id: u_order.id) if u_order.present?
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

  puts "Test updates complete: #{success_count} successful, #{error_count} errors"
  puts "\n=========================================="
  puts "TOTAL: #{order_success + success_count} successful, #{order_errors + error_count} errors"
  puts '=========================================='
ensure
  # Always remove lock file when done
  File.delete(LOCK_FILE) if File.exist?(LOCK_FILE)
  puts 'Lock released'
end
