class OrderStatus < VoidableRecord 
  validates :status_id, presence: true 
  validates :status_reason_id, presence: false

  belongs_to :order, optional: true
  belongs_to :status, optional: true
  belongs_to :status_reason, optional: true

  def as_json(options = {})
    super(options.merge(methods: %i[status initiator statuses_reason], only: %i[id order_id status_id creator status_reason_id created_date]))
  end

  def initiator
    user = User.find_by_id(creator)
    {
      username: user.username,
      first_name: user.person.first_name,
      last_name: user.person.last_name
    }
  end

  def statuses_reason
    status_reason_ = {}
    unless status_reason_id.nil?
      status_reason_= {
        id: status_reason_id,
        name: status_reason.description
      }
    end
    status_reason_
  end
end