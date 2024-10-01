# frozen_string_literal: true

# Unsync order result model
class UnsyncOrder < VoidableRecord
  after_commit :push_to_nlims, on: %i[create]

  def push_to_nlims
    NlimsSyncNowJob.perform_async(id)
  end
end
