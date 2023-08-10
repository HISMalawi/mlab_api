class StockOrder < VoidableRecord
  validates :identifier, uniqueness: true, presence: true
  has_many :stock_requisitions
  has_many :stock_order_statuses
  belongs_to :user, foreign_key: :creator
end
