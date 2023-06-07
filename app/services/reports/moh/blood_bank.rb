# frozen_string_literal: true

# Module defines methods for blood bank generating reports
module Reports
  # Generates blood bank reports
  module Moh
    class BloodBank
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
                      .where("YEAR(created_date) = #{year} AND department = 'Blood Bank'")
                      .group('MONTHNAME(created_date), indicator')
        update_report_counts(report_data)
      end

      private

      REPORT_INDICATORS = [
        'Blood grouping done on Patients',
        'Total X-matched',
        'X-matched for matenity',
        'X-matched for peads',
        'X-matched for others',
        'X-matches done on patients with Hb ≤ 6.0g/dl',
        'X-matches done on patients with Hb > 6.0g/dl',
        'Total Number Transfused with Whole blood',
        'Total Number Transfused with Packed Cells',
        'Total Number Transfused with Platelets',
        'Total Number Transfused with FFP',
        'Total Number Transfused with Cryo precipitate'
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
