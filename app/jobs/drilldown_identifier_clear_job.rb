# frozen_string_literal: true

# DrilldownIdentifierClear Job
class DrilldownIdentifierClearJob
  include Sidekiq::Job

  def perform
    DrilldownIdentifier.delete_all
  end
end
DrilldownIdentifierClearJob.perform_async
