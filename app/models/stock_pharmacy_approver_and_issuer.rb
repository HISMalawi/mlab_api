# frozen_string_literal: true

# Stock pharmacist details model
class StockPharmacyApproverAndIssuer < VoidableRecord
  has_many :stock_orders
end
