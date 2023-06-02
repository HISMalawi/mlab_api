# frozen_string_literal: true

# The module calls moh modules from moh folder
module Reports
  #  Moh service report generator service calls modules from moh folder
  module MohService
    class << self
      def report_indicators(department)
        case department.downcase
        when 'haematology'
          Reports::Moh::Haematology.new.report_indicator
        else
          []
        end
      end

      def generate_haematology_report(year)
        haema_report = Reports::Moh::Haematology.new
        haema_report.year = year
        haema_report.generate_report
      end
    end
  end
end
