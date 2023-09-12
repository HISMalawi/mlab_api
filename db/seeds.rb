# frozen_string_literal: true

stock_statuses = ['Draft', 'Pending', 'Requested', 'Received', 'Approved', 'Rejected', 'Not collected']
stock_statuses.each do |status|
  StockStatus.find_or_create_by!(
    name: status
  )
end

stock_transaction_types = ['In', 'Out', 'Reverse Issue Out Due To Rejection']
stock_transaction_types.each do |type|
  StockTransactionType.find_or_create_by!(
    name: type
  )
end
