# frozen_string_literal: true

# Module defines methods for Biochemistry generating reports
module Reports
  # Generates Biochemistry reports
  module Moh
    # Biochemistry reports
    class Biochemistry
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
                      .where("YEAR(created_date) = #{year} AND department = 'Biochemistry'")
                      .group('MONTHNAME(created_date), indicator')
        update_report_counts(report_data)
      end

      private

      REPORT_INDICATORS = [
        'Blood glucose',
        'CSF glucose',
        'Total Protein',
        'Albumin',
        'Alkaline Phosphatase(ALP)',
        'Alanine aminotransferase (ALT)',
        'Amylase',
        'Antistreptolysin O (ASO)',
        'Aspartate aminotransferase(AST)',
        'Gamma Glutamyl Transferase',
        'Bilirubin Total',
        'Bilirubin Direct',
        'Calcium',
        'Chloride',
        'Cholesterol Total',
        'Cholesterol LDL',
        'Cholesterol HDL',
        'Cholinesterase',
        'C Reactive Protein (CRP)',
        'Creatinine',
        'Creatine Kinase NAC',
        'Creatine Kinase MB',
        'Haemoglobin A1c',
        'Iron',
        'Lipase',
        'Lactate Dehydrogenase (LDH)',
        'Magnesium',
        'Micro-protein',
        'Micro-albumin',
        'Phosphorus',
        'Potassium',
        'Rheumatoid Factor',
        'Sodium',
        'Triglycerides',
        'Urea',
        'Uric acid'
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
