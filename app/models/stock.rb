# frozen_string_literal: true

# stock model
class Stock < VoidableRecord
  belongs_to :stock_item
  belongs_to :stock_location
end
