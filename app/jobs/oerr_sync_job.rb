# frozen_string_literal: true

# OERR SYNC JOB
class OerrSyncJob
  include Sidekiq::Job

  def perform
    return unless OerrService.set_to_push?

    OerrSyncTrail.where(synced: false).each do |oerr_sync_trail|
      OerrService.push_to_oerr(oerr_sync_trail)
    rescue StandardError => e
      Rails.logger.error("Error syncing OERR trail ID #{oerr_sync_trail&.id}: #{e.message}")
    end
  end
end
OerrSyncJob.perform_async
