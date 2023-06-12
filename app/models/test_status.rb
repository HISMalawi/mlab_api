# frozen_string_literal: true

# Test status model
class TestStatus < VoidableRecord
  validates :status_reason_id, presence: false
  validates :status_id, presence: true
  belongs_to :test
  belongs_to :status
  belongs_to :status_reason, optional: true

  after_commit :insert_into_report_data_raw, on: :create

  def as_json(options = {})
    super(options.merge(methods: %i[status initiator statuses_reason],
                        only: %i[id test_id status_id creator status_reason_id created_date]))
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
      status_reason_ = {
        id: status_reason_id,
        name: status_reason.description
      }
    end
    status_reason_
  end

  def insert_into_report_data_raw
    begin
      created_date = test.created_date.nil? ? '' : test.created_date.strftime('%Y-%m-%d').to_s
      InsertIntoReportRawDataJob.perform_at(1.minutes.from_now, test.id)
      UpdateMohReportDataJob.perform_at(3.minutes.from_now, created_date)
    rescue => e
      Rails.logger.error "Redis -- #{e.message} -- Check that redis is installed and running"
    end
  end
end
