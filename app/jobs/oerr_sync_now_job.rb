# frozen_string_literal: true

# OERR SYNC JOB
class OerrSyncNowJob
  include Sidekiq::Job

  def perform(id)
    oerr_sync_trail = OerrSyncTrail.find_by(id:)
    OerrService.push_to_oerr(oerr_sync_trail)
  end
end
