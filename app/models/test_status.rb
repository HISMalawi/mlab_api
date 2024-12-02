# frozen_string_literal: true

# Test status model
class TestStatus < VoidableRecord
  validates :status_reason_id, presence: false
  validates :status_id, presence: true
  belongs_to :test
  belongs_to :status
  belongs_to :status_reason, optional: true

  # after_commit :insert_into_report_data_raw, on: :create
  after_create :create_unsync_order
  after_create :create_oerr_sync_trails

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
      # created_date = test.created_date.nil? ? '' : test.created_date.strftime('%Y-%m-%d').to_s
      InsertIntoReportRawDataJob.perform_async(test.id)
      # UpdateMohReportDataJob.perform_at(1.minutes.from_now, created_date)
  rescue StandardError => e
      Rails.logger.error "Redis -- #{e.message} -- Check that redis is installed and running"
  end

  def create_unsync_order
    UnsyncOrder.create(
      test_or_order_id: test.id,
      data_not_synced: Status.find_by(id: status_id).name,
      data_level: 'test',
      sync_status: 0
    )
  end

  def create_oerr_sync_trails
    oerr_sync_trail = OerrSyncTrail.find_by(test_id: test.id)
    return if oerr_sync_trail.nil?

    OerrService.create_oerr_sync_trail_on_update(oerr_sync_trail)
  end
end
