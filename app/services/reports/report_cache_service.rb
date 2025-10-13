# frozen_string_literal: true

# ReportCacheService module
module Reports
  # ReportCacheService module
  module ReportCacheService
    class << self
      def find(id)
        report = ReportCache.find_by(id:)
        return nil if report.nil?

        serialize(report)
      end

      def create(data)
        report = ReportCache.create(data:)
        serialize(report)
      end

      def serialize(report)
        return report.data.merge(report_id: report.id) unless report.data.is_a?(Array)

        report
      end
    end
  end
end
