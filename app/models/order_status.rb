class OrderStatus < VoidableRecord 
  validates :status_id, presence: true 
  validates :status_reason_id, presence: false

  belongs_to :order
  belongs_to :status
end