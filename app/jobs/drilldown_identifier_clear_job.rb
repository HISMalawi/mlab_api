# frozen_string_literal: true

# DrilldownIdentifierClear Job
class DrilldownIdentifierClearJob
  include Sidekiq::Job

  def perform(id)
    DrilldownIdentifier.find_by(id:)&.delete
  end
end
