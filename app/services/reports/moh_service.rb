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
        when 'blood bank'
          Reports::Moh::BloodBank.new.report_indicator
        else
          []
        end
      end

      def generate_haematology_report(year)
        haema_report = Reports::Moh::Haematology.new
        haema_report.year = year
        haema_report.generate_report
      end

      def generate_blood_bank_report(year)
        blood_bank_report = Reports::Moh::BloodBank.new
        blood_bank_report.year = year
        blood_bank_report.generate_report
      end
    end
  end
end
