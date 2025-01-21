# frozen_string_literal: true

# Model for handling order statuses
class OrderStatus < VoidableRecord
  validates :status_id, presence: true
  validates :status_reason_id, presence: false

  belongs_to :order, optional: true
  belongs_to :status, optional: true
  belongs_to :status_reason, optional: true

  # after_commit :insert_into_report_data_raw, on: :create
  # after_commit :update_moh_report_data, on: :create
  after_create :create_unsync_order
  after_create :create_oerr_sync_trails

  def as_json(options = {})
    super(options.merge(methods: %i[status initiator statuses_reason],
                        only: %i[id order_id status_id creator status_reason_id created_date]))
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
    return unless %w[specimen-accepted specimen-rejected].include?(Status.find_by(id: status_id).name)

    test_ids = Test.where(order_id: order.id).pluck(:id)
    test_ids.each do |test_id|
      InsertIntoReportRawDataJob.perform_async(test_id)
    rescue StandardError => e
      Rails.logger.error "Redis -- #{e.message} -- Check that redis is installed and running"
    end
  end

  def update_moh_report_data
    return unless %w[specimen-accepted specimen-rejected].include?(Status.find_by(id: status_id).name)

    begin
      created_date = order.created_date.nil? ? '' : order.created_date.strftime('%Y-%m-%d').to_s
      UpdateMohReportDataJob.perform_at(1.minutes.from_now, created_date)
    rescue StandardError => e
      Rails.logger.error "Redis -- #{e.message} -- Check that redis is installed and running"
    end
  end

  def create_unsync_order
    return unless %w[specimen-accepted specimen-rejected].include?(Status.find_by(id: status_id).name)

    UnsyncOrder.create(
      test_or_order_id: order.id,
      data_not_synced: Status.find_by(id: status_id).name,
      data_level: 'order',
      sync_status: 0
    )
  end

  def create_oerr_sync_trails
    return unless OerrService.set_to_push?

    oerr_sync_trails = OerrSyncTrail.where(order_id: order.id)
    return if oerr_sync_trails.empty?

    return unless %w[
      specimen-accepted
      specimen-rejected
      specimen-not-collected
    ].include?(Status.find_by(id: status_id).name)

    oerr_sync_trails.each do |oerr_sync_trail|
      OerrService.create_oerr_sync_trail_on_update(oerr_sync_trail)
    end
  end
end
