# frozen_string_literal: true

# NLIMS SYNC JOB
class NlimsSyncJob
  include Sidekiq::Job

  def perform
    Nlims::Sync.create_order
    Nlims::Sync.update_order
    Nlims::Sync.update_test
  end
end
NlimsSyncJob.perform_async
