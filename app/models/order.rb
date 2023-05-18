class Order < VoidableRecord
  belongs_to :encounter
  belongs_to :priority
  has_many :tests

  after_create :create_default_status

  def create_default_status
    OrderStatus.create!(order_id: id, status_id: Status.find_by_name('specimen-not-collected').id, creator: User.current.id)
  end
end
