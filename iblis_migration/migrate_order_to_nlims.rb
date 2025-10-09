# frozen_string_literal: true

Order.where(accession_number: ['KCH2500910938', 'KCH2500910939', 'KCH2500910940', 'KCH2500910941', 'KCH2500910942', 'KCH2500910943', 'KCH2500910944', 'KCH2500910945', 'KCH2500910946', 'KCH2500910947']).each do |order|
  puts 'Processing order: ' + order.accession_number
  unsync_order = UnsyncOrder.create(
    test_or_order_id: order.id,
    data_not_synced: 'new order',
    data_level: 'order',
    sync_status: 0
  )
  begin
    sleep(1)
    Nlims::Sync.create_order_v2(id: unsync_order.id, once_off: true)
  rescue StandardError => e
    puts "Error pushing to nlims #{e.message}"
  end
end
