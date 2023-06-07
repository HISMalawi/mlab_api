# frozen_string_literal: true

# Module defines methods for Parasitology generating reports
module Reports
  # Generates Parasitology reports
  module Moh
    # parasitology reports
    class Parasitology
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
                      .where("YEAR(created_date) = #{year} AND department = 'Parasitology'")
                      .group('MONTHNAME(created_date), indicator')
        update_report_counts(report_data)
      end

      private

      REPORT_INDICATORS = [
        'Total malaria microscopy tests done',
        'Total positive malaria microscopy tests done',
        'Malaria microscopy in <= 5yrs',
        'Positive malaria slides in <= 5yrs',
        'Malaria microscopy in > 5 yrs',
        'Positive malaria slides in > 5 yrs',
        'Malaria microscopy in unknown age',
        'Positive malaria slides in unknown age',
        'Total MRDTs Done',
        'MRDTs Positives',
        'MRDTs in <= 5yrs',
        'MRDT Positives in <= 5yrs',
        'MRDTs in > 5 yrs',
        'MRDT Positives in > 5 yrs',
        'Total invalid MRDTs tests',
        'Trypanosome tests',
        'Positive tests',
        'Urine microscopy total',
        'Schistosome Haematobium',
        'Other urine parasites',
        'urine chemistry (count)',
        'Semen analysis (count)',
        'Blood Parasites (count)',
        'Blood Parasites seen',
        'Stool Microscopy (count)',
        'Stool Microscopy Parasites seen'
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
