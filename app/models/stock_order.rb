class StockOrder < VoidableRecord
  validates :identifier, uniqueness: true, presence: true
  has_many :stock_requisitions
  has_many :stock_order_statuses
  belongs_to :user, foreign_key: :creator

  def statuses
    stock_order_statuses.map do |status|
      { id: status.status_id, name: status.status_name }
    end
  end
  def requisitions
    stock_requisitions.map do |requisition|
      requisition
    end
  end
  def creattor
end
