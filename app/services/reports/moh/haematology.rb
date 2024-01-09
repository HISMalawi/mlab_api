# frozen_string_literal: true

# Module defines methods for haematology generating reports
module Reports
  # Generates haematology reports
  module Moh
    # Haematology report class
    class Haematology
      include Reports::Moh::MigrationHelpers::ExecuteQueries
      attr_reader :report, :report_indicator
      attr_accessor :year

      def initialize
        @report = {}
        @report_indicator = REPORT_INDICATORS
        initialize_report_counts
      end

      def generate_report
        # report_data = insert_into_moh_data_report_table(department: 'Haematology', time_filter: year,
        #                                                 action: 'update')
        report_data = full_blood_count + haemoglobin_only
        data = update_report_counts(report_data)
        Reports::Moh::ReportUtils.save_report_to_json('Haematology', data, year)
        data
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

      def full_blood_count
        NameMapping.find_by_sql <<~SQL
          SELECT
            MONTHNAME(t.created_date) AS month,
            COUNT(DISTINCT t.id) AS total, 'Full Blood Count' AS indicator
          FROM
              tests t
                  INNER JOIN
              test_statuses ts ON ts.test_id = t.id
          WHERE
              t.test_type_id IN #{report_utils.test_type_ids('FBC')}
                  AND YEAR(t.created_date) = #{year}
                  AND ts.status_id IN (4 , 5)
          GROUP BY MONTHNAME(t.created_date)
        SQL
      end

      def haemoglobin_only
        NameMapping.find_by_sql <<~SQL
          SELECT
            MONTHNAME(t.created_date) AS month,
            COUNT(DISTINCT t.id) AS total, 'Heamoglobin only (blood donors excluded)' AS indicator
          FROM
              tests t
                  INNER JOIN
              test_statuses ts ON ts.test_id = t.id
                  INNER JOIN
              test_indicators ti ON ti.test_type_id = t.test_type_id
                        WHERE
              t.test_type_id IN #{report_utils.test_type_ids('FBC')}
                  AND ti.id IN #{report_utils.test_indicator_ids('Haemoglobin')}
                  AND YEAR(t.created_date) = #{year}
                  AND ts.status_id IN (4 , 5)
          GROUP BY MONTHNAME(t.created_date)
        SQL
      end

      def hemacue_only
        NameMapping.find_by_sql <<~SQL
          SELECT
            MONTHNAME(t.created_date) AS month,
            COUNT(DISTINCT t.id) AS total, 'Heamoglobin only (Hemacue)' AS indicator
          FROM
              tests t
                  INNER JOIN
              test_statuses ts ON ts.test_id = t.id
                  INNER JOIN
              test_indicators ti ON ti.test_type_id = t.test_type_id
                        WHERE
              t.test_type_id IN #{report_utils.test_type_ids('Haemoglobin')}
                  AND ti.id IN #{report_utils.test_indicator_ids('Haemoglobin')}
                  AND YEAR(t.created_date) = #{year}
                  AND ts.status_id IN (4 , 5)
          GROUP BY MONTHNAME(t.created_date)
        SQL
      end

      def report_utils
        Reports::Moh::ReportUtils
      end
    end
  end
end
