# frozen_string_literal: true

# Module defines methods for haematology generating reports
module Reports
  # Generates haematology reports
  module Moh
    # Haematology report class
    class Haematology
      attr_reader :report, :report_indicator
      attr_accessor :year

      def initialize
        @report = {}
        @report_indicator = REPORT_INDICATORS
        initialize_report_counts
      end

      def generate_report
        report_data = MohReportDataMaterialized
                      .select('MONTHNAME(created_date) AS month, SUM(total) AS total, indicator')
                      .where("YEAR(created_date) = #{year} AND department IN ('Haematology', 'Paediatric Lab')")
                      .group('MONTHNAME(created_date), indicator')
        update_report_counts(report_data)
      end

      private

      REPORT_INDICATORS = [
        'Full Blood Count', 'Heamoglobin only (blood donors excluded)', 'Heamoglobin only (Hemacue)',
        'Patients with Hb ≤ 6.0g/dl', 'Patients with Hb ≤ 6.0g/dl who were transfused',
        'Patients with Hb > 6.0 g/dl', 'Patients with Hb > 6.0 g/dl who were transfused', 'WBC manual count',
        'Manual WBC differential', 'Erythrocyte Sedimentation Rate (ESR)', 'Sickling Test', 'Reticulocyte count',
        'Prothrombin time (PT)', 'Activated Partial Thromboplastin Time (APTT)',
        'International Normalized Ratio (INR)', 'Bleeding/ cloting time', 'CD4 absolute count', 'CD4 percentage',
        'Blood film for red cell morphology'
      ].freeze

      def initialize_report_counts
        I18n.t('date.month_names').compact.map(&:downcase).each do |month_name|
          @report[month_name] = {}
          REPORT_INDICATORS.each do |indicator|
            @report[month_name][indicator.to_sym] = 0
          end
        end
      end

      def update_report_counts(counts)
        counts.each do |count|
          month_name = count.month.downcase
          REPORT_INDICATORS.each do |_indicator|
            @report[month_name][count.indicator.to_sym] = count.total
          end
        end
        @report
      end
    end
  end
end
