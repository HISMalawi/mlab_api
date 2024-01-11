# frozen_string_literal: true

# Module defines methods for blood bank generating reports
module Reports
  # Generates blood bank reports
  module Moh
    # bloodbank reports
    class BloodBank
      include Reports::Moh::MigrationHelpers::ExecuteQueries
      attr_reader :report, :report_indicator
      attr_accessor :year

      def initialize
        @report = {}
        @report_indicator = REPORT_INDICATORS
        initialize_report_counts
      end

      def generate_report
        report_data = blood_grouping_on_patient + x_match + x_match_maternity + x_match_paeds +
                      x_match_other + patient_with_hb_greater_6_transfused + patient_with_hb_less_equal_6_transfused
        data = update_report_counts(report_data)
        Reports::Moh::ReportUtils.save_report_to_json('Blood Bank', data, year)
        data
      end

      private

      REPORT_INDICATORS = [
        'Blood grouping done on Patients',
        'Total X-matched',
        'X-matched for matenity',
        'X-matched for peads',
        'X-matched for others',
        'X-matches done on patients with Hb ≤ 6.0g/dl',
        'X-matches done on patients with Hb > 6.0 g/dl',
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

      def blood_grouping_on_patient
        Report.find_by_sql <<~SQL
          SELECT
            MONTHNAME(t.created_date) AS month,
            COUNT(DISTINCT t.id) AS total, 'Blood grouping done on Patients' AS indicator
          FROM
              tests t
                  INNER JOIN
              test_statuses ts ON ts.test_id = t.id
                        WHERE
              t.test_type_id IN #{report_utils.test_type_ids('ABO Blood Grouping')}
                  AND YEAR(t.created_date) = #{year}
                  AND ts.status_id IN (4 , 5)
                  AND t.voided = 0
          GROUP BY MONTHNAME(t.created_date)
        SQL
      end

      def x_match
        Report.find_by_sql <<~SQL
          SELECT
            MONTHNAME(t.created_date) AS month,
            COUNT(DISTINCT t.id) AS total, 'Total X-matched' AS indicator
          FROM
              tests t
                  INNER JOIN
              test_statuses ts ON ts.test_id = t.id
                        WHERE
              t.test_type_id IN #{report_utils.test_type_ids('Cross-match')}
                  AND YEAR(t.created_date) = #{year}
                  AND ts.status_id IN (4 , 5)
                  AND t.voided = 0
          GROUP BY MONTHNAME(t.created_date)
        SQL
      end

      def x_match_maternity
        Report.find_by_sql <<~SQL
          SELECT
            MONTHNAME(t.created_date) AS month,
            COUNT(DISTINCT t.id) AS total, 'X-matched for matenity' AS indicator
          FROM
              tests t
                  INNER JOIN
              orders o ON o.id = t.order_id AND o.voided = 0
                  INNER JOIN
              encounters e ON e.id = o.encounter_id AND e.voided = 0 AND e.facility_section_id
                  IN #{report_utils.facility_section_ids('Maternity')}
                  INNER JOIN
              test_statuses ts ON ts.test_id = t.id
                        WHERE
              t.test_type_id IN #{report_utils.test_type_ids('Cross-match')}
                  AND YEAR(t.created_date) = #{year}
                  AND ts.status_id IN (4 , 5)
                  AND t.voided = 0
          GROUP BY MONTHNAME(t.created_date)
        SQL
      end

      def x_match_paeds
        Report.find_by_sql <<~SQL
          SELECT
            MONTHNAME(t.created_date) AS month,
            COUNT(DISTINCT t.id) AS total, 'X-matched for peads' AS indicator
          FROM
              tests t
                  INNER JOIN
              orders o ON o.id = t.order_id AND o.voided = 0
                  INNER JOIN
              encounters e ON e.id = o.encounter_id AND e.voided = 0 AND e.facility_section_id
                  IN #{report_utils.facility_section_ids('paeds')}
                  INNER JOIN
              test_statuses ts ON ts.test_id = t.id
                        WHERE
              t.test_type_id IN #{report_utils.test_type_ids('Cross-match')}
                  AND YEAR(t.created_date) = #{year}
                  AND ts.status_id IN (4 , 5)
                  AND t.voided = 0
          GROUP BY MONTHNAME(t.created_date)
        SQL
      end

      def x_match_other
        Report.find_by_sql <<~SQL
          SELECT
            MONTHNAME(t.created_date) AS month,
            COUNT(DISTINCT t.id) AS total, 'X-matched for others' AS indicator
          FROM
              tests t
                  INNER JOIN
              orders o ON o.id = t.order_id AND o.voided = 0
                  INNER JOIN
              encounters e ON e.id = o.encounter_id AND e.voided = 0 AND e.facility_section_id
                  NOT IN #{report_utils.facility_section_ids(%w[paeds Maternity])}
                  INNER JOIN
              test_statuses ts ON ts.test_id = t.id
                        WHERE
              t.test_type_id IN #{report_utils.test_type_ids('Cross-match')}
                  AND YEAR(t.created_date) = #{year}
                  AND ts.status_id IN (4 , 5)
                  AND t.voided = 0
          GROUP BY MONTHNAME(t.created_date)
        SQL
      end

      def patient_with_hb_less_equal_6_transfused
        Report.find_by_sql <<~SQL
          SELECT
            MONTHNAME(ot.created_date) AS month,
            COUNT(DISTINCT ot.id) AS total,
            'X-matches done on patients with Hb ≤ 6.0g/dl' AS indicator
          FROM
              tests ot
                  INNER JOIN
              test_statuses ots ON ots.test_id = ot.id
                  INNER JOIN
              test_indicators oti ON oti.test_type_id = ot.test_type_id
                  INNER JOIN
              orders oo ON oo.id = ot.order_id
                  INNER JOIN
              encounters oe ON oe.id = oo.encounter_id
          WHERE
              oe.client_id IN (SELECT DISTINCT
                      e.client_id
                  FROM
                      tests t
                          INNER JOIN
                      test_statuses ts ON ts.test_id = t.id
                          INNER JOIN
                      test_indicators ti ON ti.test_type_id = t.test_type_id
                          INNER JOIN
                      orders o ON o.id = t.order_id
                          INNER JOIN
                      encounters e ON e.id = o.encounter_id
                          INNER JOIN
                      test_results tr ON tr.test_indicator_id = ti.id
                          AND tr.test_id = t.id
                          AND tr.voided = 0
                  WHERE
                      t.test_type_id IN #{report_utils.test_type_ids(%w[Haemoglobin FBC])}
                          AND ti.id IN #{report_utils.test_indicator_ids('Haemoglobin')}
                          AND YEAR(t.created_date) = #{year}
                          AND ts.status_id IN (4 , 5)
                          AND t.voided = 0
                          AND tr.value <= 6
                          AND tr.value <> ''
                          AND tr.value IS NOT NULL)
                  AND ot.voided = 0
                  AND ot.test_type_id IN #{report_utils.test_type_ids('Cross-match')}
                  AND oti.id IN #{report_utils.test_indicator_ids('Pack ABO Group')}
                  AND ots.status_id IN (4 , 5)
          GROUP BY MONTHNAME(ot.created_date)
        SQL
      end

      def patient_with_hb_greater_6_transfused
        Report.find_by_sql <<~SQL
          SELECT
            MONTHNAME(ot.created_date) AS month,
            COUNT(DISTINCT ot.id) AS total,
            'X-matches done on patients with Hb > 6.0 g/dl' AS indicator
          FROM
              tests ot
                  INNER JOIN
              test_statuses ots ON ots.test_id = ot.id
                  INNER JOIN
              test_indicators oti ON oti.test_type_id = ot.test_type_id
                  INNER JOIN
              orders oo ON oo.id = ot.order_id
                  INNER JOIN
              encounters oe ON oe.id = oo.encounter_id
          WHERE
              oe.client_id IN (SELECT DISTINCT
                      e.client_id
                  FROM
                      tests t
                          INNER JOIN
                      test_statuses ts ON ts.test_id = t.id
                          INNER JOIN
                      test_indicators ti ON ti.test_type_id = t.test_type_id
                          INNER JOIN
                      orders o ON o.id = t.order_id
                          INNER JOIN
                      encounters e ON e.id = o.encounter_id
                          INNER JOIN
                      test_results tr ON tr.test_indicator_id = ti.id
                          AND tr.test_id = t.id
                          AND tr.voided = 0
                  WHERE
                      t.test_type_id IN #{report_utils.test_type_ids(%w[Haemoglobin FBC])}
                          AND ti.id IN #{report_utils.test_indicator_ids('Haemoglobin')}
                          AND YEAR(t.created_date) = #{year}
                          AND ts.status_id IN (4 , 5)
                          AND t.voided = 0
                          AND tr.value > 6
                          AND tr.value <> ''
                          AND tr.value IS NOT NULL)
                  AND ot.voided = 0
                  AND ot.test_type_id IN #{report_utils.test_type_ids('Cross-match')}
                  AND oti.id IN #{report_utils.test_indicator_ids('Pack ABO Group')}
                  AND ots.status_id IN (4 , 5)
          GROUP BY MONTHNAME(ot.created_date)
        SQL
      end

      def report_utils
        Reports::Moh::ReportUtils
      end
    end
  end
end
