# frozen_string_literal: true

# Stock pharmacist details model
class StockPharmacyApproverAndIssuer < VoidableRecord
  validates :name, presence: true
  has_many :stock_orders
end
