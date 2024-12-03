# frozen_string_literal: true

# OerrSyncTrail model
class OerrSyncTrail < VoidableRecord
  self.table_name = 'oerr_sync_trails'
  after_create :push_to_oerr

  def as_json(options = {})
    super(options.merge({ only: %i[id order_id test_id npid facility_section_id requested_by sample_collected_time
                                   doc_id] }))
  end

  private

  def push_to_oerr
    OerrSyncNowJob.perform_async(id)
  rescue StandardError => e
    puts "Error pushing to oerr #{e.message}"
  end
end
