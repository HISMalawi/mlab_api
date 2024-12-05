# frozen_string_literal: true

# Unsync order result model
class UnsyncOrder < VoidableRecord
  after_commit :push_to_nlims, on: %i[create]

  def push_to_nlims
    nlims = Nlims::Sync.nlims_token
    if nlims[:token].present? && nlims[:base_url].present? && nlims[:enable_real_time_sync].present?
      NlimsSyncNowJob.perform_async(id)
    end
  rescue StandardError => e
    puts "Error pushing to nlims #{e.message}"
  end
end
