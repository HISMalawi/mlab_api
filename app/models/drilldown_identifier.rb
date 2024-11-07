# frozen_string_literal: true

# DrilldownIdentifier model
class DrilldownIdentifier < VoidableRecord
  before_create :set_uuid
  after_create :clear_drilldown_identifier_cache
  self.table_name = 'drilldown_identifiers'

  private

  def set_uuid
    self.id = SecureRandom.uuid if id.blank?
  end

  def clear_drilldown_identifier_cache
    DrilldownIdentifierClearJob.perform_at(24.hours.from_now, id)
  rescue StandardError => e
    puts "Error:
     #{e.message}"
  end
end
