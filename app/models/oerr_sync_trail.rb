# frozen_string_literal: true

# OerrSyncTrail model
class OerrSyncTrail < VoidableRecord
  self.table_name = 'oerr_sync_trails'
  after_commit :push_to_oerr, on: :create

  def as_json(options = {})
    super(options.merge(
      {
        only: %i[id order_id test_id npid facility_section_id requested_by doc_id],
        methods: %i[test_type_id sample_collected_at is_panel]
      }
    ))
  end

  def test_type_id
    Test.find_by(id: test_id).test_type_id
  end

  def is_panel
    Test.find_by(id: test_id).test_panel_id.present?
  end

  def sample_collected_at
    Time.at(sample_collected_time).to_i
  end

  private

  def push_to_oerr
    return unless OerrService.set_to_push?

    OerrSyncNowJob.perform_async(id)
  rescue StandardError => e
    puts "Error pushing to oerr #{e.message}"
  end
end
