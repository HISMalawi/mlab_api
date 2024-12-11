# frozen_string_literal: true

# NLIMS SYNC JOB
class NlimsSyncJob
  include Sidekiq::Job

  def perform
    nlims = Nlims::Sync.nlims_token
    return unless nlims[:token].present? && nlims[:base_url].present?

      Nlims::Sync.create_order
      Nlims::Sync.update_order
      Nlims::Sync.update_test
  end
end
NlimsSyncJob.perform_async
