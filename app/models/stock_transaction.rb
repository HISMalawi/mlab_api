# frozen_string_literal: true

# stock transaction model
class StockTransaction < VoidableRecord
    belongs_to :stock
end
