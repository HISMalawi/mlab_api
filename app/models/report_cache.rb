# frozen_string_literal: true

# ReportCache model
class ReportCache < VoidableRecord
  before_create :set_uuid
  after_create :clear_report_cache

  private

  def set_uuid
    self.id = SecureRandom.uuid if id.blank?
  end

  def clear_report_cache
    ReportCacheClearJob.perform_at(2.hours.from_now, id)
  rescue StandardError => e
    puts "Error:
     #{e.message}"
  end
end
