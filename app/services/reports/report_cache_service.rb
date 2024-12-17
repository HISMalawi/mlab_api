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
        report.data.merge(report_id: report.id)
      end
    end
  end
end
