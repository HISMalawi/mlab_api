# frozen_string_literal: true

# NLIMS SYNC JOB
class NlimsSyncNowJob
  include Sidekiq::Job

  def perform(id)
    nlims = Nlims::Sync.nlims_token
    return unless nlims[:token].present? && nlims[:base_url].present?

    Nlims::Sync.create_order_v2(id:)
    Nlims::Sync.update_order(id:)
    Nlims::Sync.sync_add_test_to_order(id:)
    Nlims::Sync.update_test_v2(id:)
  end
end
