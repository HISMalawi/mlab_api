# frozen_string_literal: true

# ReportCacheClearJob Job
class ReportCacheClearJob
  include Sidekiq::Job

  def perform(id)
    ReportCache.find_by(id:)&.delete
  end
end
