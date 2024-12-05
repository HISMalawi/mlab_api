# frozen_string_literal: true

# NLIMS SYNC JOB
class NlimsSyncNowJob
  include Sidekiq::Job

  def perform(id)
    nlims = Nlims::Sync.nlims_token
    return unless nlims[:token].present? && nlims[:base_url].present? && nlims[:enable_real_time_sync].present?

      Nlims::Sync.create_order(id:)
      Nlims::Sync.update_order(id:)
      Nlims::Sync.update_test(id:)
  end
end
