# frozen_string_literal: true

# ReportCacheService module
module Reports
  # ReportCacheService module
  module ReportCacheService
    class << self
      def find_or_create_cache(id, data)
        report = ReportCache.find_or_create_by(id:) do |cache|
          cache.data = data
        end
        report.data.merge(report_id: report.id)
      end
    end
  end
end
