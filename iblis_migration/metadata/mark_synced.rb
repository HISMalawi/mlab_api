# frozen_string_literal: true

# Set sync status to sync for orders except those explicitly stated

puts 'Setting sync status to sync for orders except those explicitly stated'
orders = Order.where("tracking_number NOT LIKE 'XAETC%'")
order_ids = orders.pluck(:id)
test_ids = Test.where(order_id: order_ids).pluck(:id)

puts "Found #{order_ids.count} orders and #{test_ids.count} tests"

# Update order level
UnsyncOrder.where(test_or_order_id: order_ids, data_level: 'order', sync_status: false).update_all(sync_status: true)
puts 'Updated order level sync status'

# Update test level
UnsyncOrder.where(test_or_order_id: test_ids, data_level: 'test', sync_status: false).update_all(sync_status: true)
puts 'Updated test level sync status'

# Clear all Sidekiq jobs
puts "\nClearing all Sidekiq jobs..."

# Clear retry set
retry_set = Sidekiq::RetrySet.new
retry_count = retry_set.size
retry_set.clear
puts "Cleared #{retry_count} retries"

# Clear scheduled set
scheduled_set = Sidekiq::ScheduledSet.new
scheduled_count = scheduled_set.size
scheduled_set.clear
puts "Cleared #{scheduled_count} scheduled jobs"

# Clear dead set
dead_set = Sidekiq::DeadSet.new
dead_count = dead_set.size
dead_set.clear
puts "Cleared #{dead_count} dead jobs"

# Clear all queues (enqueued jobs)
queue_count = 0
Sidekiq::Queue.all.each do |queue|
  queue_count += queue.size
  queue.clear
end
puts "Cleared #{queue_count} enqueued jobs from all queues"

# Clear stats (processed and failed counters)
stats = Sidekiq::Stats.new
stats.reset
puts 'Reset processed and failed stats'

puts "\nClear DrillDown Identifiers..."
DrilldownIdentifier.delete_all

puts "\nDone"
