# frozen_string_literal: true

# Module defines methods for Serology generating reports
module Reports
  # Generates Serology reports
  module Moh
    # Serology reports
    class Serology
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
                      .where("YEAR(created_date) = #{year} AND department = 'Serology'")
                      .group('MONTHNAME(created_date), indicator')
        update_report_counts(report_data)
      end

      private

      REPORT_INDICATORS = [
        'Syphilis screening on patients',
        'Syphilis Positive tests',
        'Syphilis screening on antenatal mothers',
        'Syphilis Positive tests on antenatal mothers',
        'HepBsAg test done on patients',
        'HepBsAg Positive tests',
        'HepCcAg test done on patients',
        'HepCcAg Positive tests',
        'Hcg Pregnacy tests done',
        'Hcg Pregnacy Positive tests',
        'HIV tests on PEP patients',
        'HIV PEP positives tests',
        'Prostate Specific Antigen (PSA) tests',
        'PSA Positive',
        'SARs- COVID-19 rapid antigen tests',
        'SARs-COVID 19 Positive',
        'Serum Crag',
        'Serum Crag Positive'
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
