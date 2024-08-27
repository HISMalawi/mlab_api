# frozen_string_literal: true

# DrilldownIdentifier model
class DrilldownIdentifier < VoidableRecord
  before_create :set_uuid
  self.table_name = 'drilldown_identifiers'

  private

  def set_uuid
    self.id = SecureRandom.uuid if id.blank?
  end
end
