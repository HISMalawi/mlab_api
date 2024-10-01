# frozen_string_literal: true

# NLIMS SYNC JOB
class NlimsSyncNowJob
  include Sidekiq::Job

  def perform(id)
    Nlims::Sync.create_order(id:)
    Nlims::Sync.update_order(id:)
    Nlims::Sync.update_test(id:)
  end
end
