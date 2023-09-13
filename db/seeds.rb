# frozen_string_literal: true

stock_statuses = ['Draft', 'Pending', 'Requested', 'Received', 'Approved', 'Rejected', 'Not collected']
stock_statuses.each do |status|
  puts "Creating stock status: #{status}"
  StockStatus.find_or_create_by!(
    name: status
  )
end

stock_transaction_types = ['In', 'Out', 'Reverse Issue Out Due To Rejection', 'Adjust Stock']
stock_transaction_types.each do |type|
  puts "Creating stock transaction type: #{type}"
  StockTransactionType.find_or_create_by!(
    name: type
  )
end

stock_adjustment_reasons = ['Damaged', 'Expired', 'Lost', 'Theft', 'Other']
stock_adjustment_reasons.each do |reason|
  puts "Creating stock adjustment reason: #{reason}"
  StockAdjustmentReason.find_or_create_by!(name: reason)
end
