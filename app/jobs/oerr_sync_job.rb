# frozen_string_literal: true

# OERR SYNC JOB
class OerrSyncJob
  include Sidekiq::Job

  def perform
    OerrSyncTrail.where(synced: false).each do |oerr_sync_trail|
      OerrService.push_to_oerr(oerr_sync_trail)
    end
  end
end
OerrSyncJob.perform_async
