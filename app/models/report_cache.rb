# frozen_string_literal: true

# ReportCache model
class ReportCache < VoidableRecord
  before_create :set_uuid

  private

  def set_uuid
    self.id = SecureRandom.uuid if id.blank?
  end
end
