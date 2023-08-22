# frozen_string_literal: true

stock_statuses = ['Draft', 'Pending', 'Requested', 'Received', 'Approved', 'Rejected', 'Not collected']
stock_statuses.each do |status|
  StockStatus.find_or_create_by!(
    name: status
  )
end
