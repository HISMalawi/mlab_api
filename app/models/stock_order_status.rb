# frozen_string_literal: true

# stock order status model
class StockOrderStatus < VoidableRecord
  belongs_to :stock_order
  belongs_to :stock_status

  def as_json(options = {})
    methods = %i[initiator stock_status]
    super(options.merge(methods:, only: %i[id stock_order_id created_date updated_date]))
  end

  def initiator
    user = User.find_by_id(creator)
    {
      id: user.id,
      username: user.username,
      first_name: user.person.first_name,
      last_name: user.person.last_name
    }
  end
end
