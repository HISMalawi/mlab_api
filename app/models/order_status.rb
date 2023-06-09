class OrderStatus < VoidableRecord 
  validates :status_id, presence: true 
  validates :status_reason_id, presence: false

  belongs_to :order, optional: true
  belongs_to :status, optional: true
  belongs_to :status_reason, optional: true

  after_create :insert_into_report_data_raw

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

  def insert_into_report_data_raw
    test_ids = Test.where(order_id: order.id).pluck(:id)
    test_ids.each do |test_id|
      begin
        InsertIntoReportRawDataJob.perform_at(2.minutes.from_now, test_id)
      rescue => exception
        Rails.logger.error "Redis -- #{exception.message} -- Check that redis is installed and running"
      end
    end
  end
end