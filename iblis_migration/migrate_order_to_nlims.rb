# frozen_string_literal: true

unsynced_orders = UnsyncOrder.where(data_not_synced: 'new order', sync_status: 0)
thread_count = 4
unsynced_orders.in_batches(of: 500) do |batch|
  Parallel.each(batch, in_threads: thread_count) do |unsynced_order|
    ActiveRecord::Base.connection_pool.with_connection do
      puts "Processing unsynced order: #{unsynced_order.id}"
      Nlims::Sync.create_order_v2(id: unsynced_order.id, once_off: true)
    rescue StandardError => e
      puts "Error pushing order #{unsynced_order.id} to nlims: #{e.message}"
    end
  end
end

unsynced_ids = UnsyncOrder.where(data_not_synced: 'new order').select(:test_or_order_id)
scope = Order.where.not(id: unsynced_ids)
User.current = User.first

scope.in_batches(of: 500) do |batch|
  Parallel.each(batch, in_threads: thread_count) do |order|
    ActiveRecord::Base.connection_pool.with_connection do
      puts "Processing order: #{order.tracking_number}"

      unsync_order = UnsyncOrder.create!(
        test_or_order_id: order.id,
        data_not_synced: 'new order',
        data_level: 'order',
        sync_status: 0
      )

      Nlims::Sync.create_order_v2(id: unsync_order.id, once_off: true)
    rescue StandardError => e
      puts "Error pushing order #{order.tracking_number} to nlims: #{e.message}"
    end
  end

  puts "Completed batch up to order ID #{batch.last.id}"
end
