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
        when 'biochemistry'
          Reports::Moh::Biochemistry.new.report_indicator
        when 'parasitology'
          Reports::Moh::Parasitology.new.report_indicator
        when 'microbiology'
          Reports::Moh::Microbiology.new.report_indicator
        when 'serology'
          Reports::Moh::Serology.new.report_indicator
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

      def generate_biochemistry_report(year)
        biochemistry_report = Reports::Moh::Biochemistry.new
        biochemistry_report.year = year
        biochemistry_report.generate_report
      end

      def generate_parasitology_report(year)
        parasitology_report = Reports::Moh::Parasitology.new
        parasitology_report.year = year
        parasitology_report.generate_report
      end

      def generate_microbiology_report(year)
        microbiology_report = Reports::Moh::Microbiology.new
        microbiology_report.year = year
        microbiology_report.generate_report
      end

      def generate_serology_report(year)
        serology_report = Reports::Moh::Serology.new
        serology_report.year = year
        serology_report.generate_report
      end
    end
  end
end
