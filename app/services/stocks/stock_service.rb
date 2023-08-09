module Stocks
  class StockService
    def initialize(order_params, requisitions_params)
      @order_params = order_params
      @requisitions_params = requisitions_params
    end

    def create_order_and_requisitions
      ActiveRecord::Base.transaction do
        order = create_order
        status = Status.find_by(name: 'pending').id
        create_requisitions(order)
        create_status_trail(order, status)
      end
      { message: 'Stock order and requisitions created successfully' }
    rescue StandardError => e
      { error: e.message }
    end

    private

    def create_order
      StockOrder.create!(@order_params)
    end

    def create_requisitions(order)
      @requisitions_params.each do |requisition_params|
        order.stock_requisitions.create!(requisition_params)
      end
    end

    def create_status_trail(order, status)
      order.stock_order_statuses.create!(status_id: status)
    end
  end
end
