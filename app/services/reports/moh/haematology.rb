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
        report_data = full_blood_count + haemoglobin_only + hemacue_only + patient_with_hb_less_equal_6 +
                      patient_with_hb_greater_6 + patient_with_hb_less_equal_6_transfused +
                      patient_with_hb_greater_6_transfused + manual_wbc_differential + wbc_manual + esr +
                      sickling_test + ret_count + inr + aptt + pt + cd4_abs_count + cd4_percent + blood_film_morph
        data = update_report_counts(report_data)
        Report.find_or_create_by(name: 'moh_haematology', year:).update(data:)
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
        Report.find_by_sql <<~SQL
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
                  AND t.voided = 0
          GROUP BY MONTHNAME(t.created_date)
        SQL
      end

      def haemoglobin_only
        Report.find_by_sql <<~SQL
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
                  AND t.voided = 0
          GROUP BY MONTHNAME(t.created_date)
        SQL
      end

      def hemacue_only
        Report.find_by_sql <<~SQL
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
                  AND t.voided = 0
          GROUP BY MONTHNAME(t.created_date)
        SQL
      end

      def patient_with_hb_less_equal_6
        Report.find_by_sql <<~SQL
          SELECT
            MONTHNAME(t.created_date) AS month,
            COUNT(DISTINCT t.id) AS total, 'Patients with Hb ≤ 6.0g/dl' AS indicator
          FROM
              tests t
                  INNER JOIN
              test_statuses ts ON ts.test_id = t.id
                  INNER JOIN
              test_indicators ti ON ti.test_type_id = t.test_type_id
                  INNER JOIN
              test_results tr ON tr.test_indicator_id = ti.id AND tr.test_id = t.id AND tr.voided = 0
                        WHERE
              t.test_type_id IN #{report_utils.test_type_ids(%w[Haemoglobin FBC])}
                  AND ti.id IN #{report_utils.test_indicator_ids('Haemoglobin')}
                  AND YEAR(t.created_date) = #{year}
                  AND ts.status_id IN (4 , 5)
                  AND t.voided = 0
                  AND tr.value <= 6
                  AND tr.value <> ''
                  AND tr.value IS NOT NULL
          GROUP BY MONTHNAME(t.created_date)
        SQL
      end

      def patient_with_hb_greater_6
        Report.find_by_sql <<~SQL
          SELECT
            MONTHNAME(t.created_date) AS month,
            COUNT(DISTINCT t.id) AS total, 'Patients with Hb > 6.0 g/dl' AS indicator
          FROM
              tests t
                  INNER JOIN
              test_statuses ts ON ts.test_id = t.id
                  INNER JOIN
              test_indicators ti ON ti.test_type_id = t.test_type_id
                  INNER JOIN
              test_results tr ON tr.test_indicator_id = ti.id AND tr.test_id = t.id AND tr.voided = 0
                        WHERE
              t.test_type_id IN #{report_utils.test_type_ids(%w[Haemoglobin FBC])}
                  AND ti.id IN #{report_utils.test_indicator_ids('Haemoglobin')}
                  AND YEAR(t.created_date) = #{year}
                  AND ts.status_id IN (4 , 5)
                  AND t.voided = 0
                  AND tr.value > 6
                  AND tr.value <> ''
                  AND tr.value IS NOT NULL
          GROUP BY MONTHNAME(t.created_date)
        SQL
      end

      def patient_with_hb_less_equal_6_transfused
        Report.find_by_sql <<~SQL
          SELECT
            MONTHNAME(ot.created_date) AS month,
            COUNT(DISTINCT ot.id) AS total,
            'Patients with Hb ≤ 6.0g/dl who were transfused' AS indicator
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
            'Patients with Hb > 6.0 g/dl who were transfused' AS indicator
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

      def wbc_manual
        Report.find_by_sql <<~SQL
          SELECT
            MONTHNAME(t.created_date) AS month,
            COUNT(DISTINCT t.id) AS total, 'WBC manual count' AS indicator
          FROM
              tests t
                  INNER JOIN
              test_statuses ts ON ts.test_id = t.id
          WHERE
              t.test_type_id IN #{report_utils.test_type_ids('Manual Differential & Cell Morphology')}
                  AND YEAR(t.created_date) = #{year}
                  AND ts.status_id IN (4 , 5)
                  AND t.voided = 0
          GROUP BY MONTHNAME(t.created_date)
        SQL
      end

      def manual_wbc_differential
        Report.find_by_sql <<~SQL
          SELECT
            MONTHNAME(t.created_date) AS month,
            COUNT(DISTINCT t.id) AS total, 'Manual WBC differential' AS indicator
          FROM
              tests t
                  INNER JOIN
              test_statuses ts ON ts.test_id = t.id
          WHERE
              t.test_type_id IN #{report_utils.test_type_ids('Manual Differential & Cell Morphology')}
                  AND YEAR(t.created_date) = #{year}
                  AND ts.status_id IN (4 , 5)
                  AND t.voided = 0
          GROUP BY MONTHNAME(t.created_date)
        SQL
      end

      def esr
        Report.find_by_sql <<~SQL
          SELECT
            MONTHNAME(t.created_date) AS month,
            COUNT(DISTINCT t.id) AS total, 'Erythrocyte Sedimentation Rate (ESR)' AS indicator
          FROM
              tests t
                  INNER JOIN
              test_statuses ts ON ts.test_id = t.id
          WHERE
              t.test_type_id IN #{report_utils.test_type_ids('ESR')}
                  AND YEAR(t.created_date) = #{year}
                  AND ts.status_id IN (4 , 5)
                  AND t.voided = 0
          GROUP BY MONTHNAME(t.created_date)
        SQL
      end

      def sickling_test
        Report.find_by_sql <<~SQL
          SELECT
            MONTHNAME(t.created_date) AS month,
            COUNT(DISTINCT t.id) AS total, 'Sickling Test' AS indicator
          FROM
              tests t
                  INNER JOIN
              test_statuses ts ON ts.test_id = t.id
          WHERE
              t.test_type_id IN #{report_utils.test_type_ids('Sickling Test')}
                  AND YEAR(t.created_date) = #{year}
                  AND ts.status_id IN (4 , 5)
                  AND t.voided = 0
          GROUP BY MONTHNAME(t.created_date)
        SQL
      end

      def ret_count
        Report.find_by_sql <<~SQL
          SELECT
            MONTHNAME(t.created_date) AS month,
            COUNT(DISTINCT t.id) AS total, 'Reticulocyte count' AS indicator
          FROM
              tests t
                  INNER JOIN
              test_statuses ts ON ts.test_id = t.id
                  INNER JOIN
              test_indicators ti ON ti.test_type_id = t.test_type_id
                  INNER JOIN
              test_results tr ON tr.test_indicator_id = ti.id
                  AND tr.test_id = t.id
                  AND tr.voided = 0
          WHERE
              t.test_type_id IN #{report_utils.test_type_ids(%w[FBC])}
                  AND ti.id IN #{report_utils.test_indicator_ids('RET#')}
                  AND YEAR(t.created_date) = #{year}
                  AND ts.status_id IN (4 , 5)
                  AND t.voided = 0
                  AND tr.value <> ''
                  AND tr.value IS NOT NULL
          GROUP BY MONTHNAME(t.created_date)
        SQL
      end

      def pt
        Report.find_by_sql <<~SQL
          SELECT
            MONTHNAME(t.created_date) AS month,
            COUNT(DISTINCT t.id) AS total, 'Prothrombin time (PT)' AS indicator
          FROM
              tests t
                  INNER JOIN
              test_statuses ts ON ts.test_id = t.id
          WHERE
              t.test_type_id IN #{report_utils.test_type_ids('Prothrombin Time')}
                  AND YEAR(t.created_date) = #{year}
                  AND ts.status_id IN (4 , 5)
                  AND t.voided = 0
          GROUP BY MONTHNAME(t.created_date)
        SQL
      end

      def aptt
        Report.find_by_sql <<~SQL
          SELECT
            MONTHNAME(t.created_date) AS month,
            COUNT(DISTINCT t.id) AS total, 'Activated Partial Thromboplastin Time (APTT)' AS indicator
          FROM
              tests t
                  INNER JOIN
              test_statuses ts ON ts.test_id = t.id
          WHERE
              t.test_type_id IN #{report_utils.test_type_ids('APTT')}
                  AND YEAR(t.created_date) = #{year}
                  AND ts.status_id IN (4 , 5)
                  AND t.voided = 0
          GROUP BY MONTHNAME(t.created_date)
        SQL
      end

      def inr
        Report.find_by_sql <<~SQL
          SELECT
            MONTHNAME(t.created_date) AS month,
            COUNT(DISTINCT t.id) AS total, 'International Normalized Ratio (INR)' AS indicator
          FROM
              tests t
                  INNER JOIN
              test_statuses ts ON ts.test_id = t.id
          WHERE
              t.test_type_id IN #{report_utils.test_type_ids('INR')}
                  AND YEAR(t.created_date) = #{year}
                  AND ts.status_id IN (4 , 5)
                  AND t.voided = 0
          GROUP BY MONTHNAME(t.created_date)
        SQL
      end

      def bleeding_clotting
        Report.find_by_sql <<~SQL
          SELECT
            MONTHNAME(t.created_date) AS month,
            COUNT(DISTINCT t.id) AS total, 'Bleeding/ cloting time' AS indicator
          FROM
              tests t
                  INNER JOIN
              test_statuses ts ON ts.test_id = t.id
          WHERE
              t.test_type_id IN #{report_utils.test_type_ids('Bleeding Time')}
                  AND YEAR(t.created_date) = #{year}
                  AND ts.status_id IN (4 , 5)
                  AND t.voided = 0
          GROUP BY MONTHNAME(t.created_date)
        SQL
      end

      def cd4_abs_count
        Report.find_by_sql <<~SQL
          SELECT
            MONTHNAME(t.created_date) AS month,
            COUNT(DISTINCT t.id) AS total, 'CD4 absolute count' AS indicator
          FROM
              tests t
                  INNER JOIN
              test_statuses ts ON ts.test_id = t.id
                  INNER JOIN
              test_indicators ti ON ti.test_type_id = t.test_type_id
                  INNER JOIN
              test_results tr ON tr.test_indicator_id = ti.id
                  AND tr.test_id = t.id
                  AND tr.voided = 0
          WHERE
              t.test_type_id IN #{report_utils.test_type_ids(%w[CD4])}
                  AND ti.id IN #{report_utils.test_indicator_ids('CD4 Count')}
                  AND YEAR(t.created_date) = #{year}
                  AND ts.status_id IN (4 , 5)
                  AND t.voided = 0
                  AND tr.value <> ''
                  AND tr.value IS NOT NULL
          GROUP BY MONTHNAME(t.created_date)
        SQL
      end

      def cd4_percent
        Report.find_by_sql <<~SQL
          SELECT
            MONTHNAME(t.created_date) AS month,
            COUNT(DISTINCT t.id) AS total, 'CD4 percentage' AS indicator
          FROM
              tests t
                  INNER JOIN
              test_statuses ts ON ts.test_id = t.id
                  INNER JOIN
              test_indicators ti ON ti.test_type_id = t.test_type_id
                  INNER JOIN
              test_results tr ON tr.test_indicator_id = ti.id
                  AND tr.test_id = t.id
                  AND tr.voided = 0
          WHERE
              t.test_type_id IN #{report_utils.test_type_ids(%w[CD4])}
                  AND ti.id IN #{report_utils.test_indicator_ids('CD4 %#')}
                  AND YEAR(t.created_date) = #{year}
                  AND ts.status_id IN (4 , 5)
                  AND t.voided = 0
                  AND tr.value <> ''
                  AND tr.value IS NOT NULL
          GROUP BY MONTHNAME(t.created_date)
        SQL
      end

      def blood_film_morph
        Report.find_by_sql <<~SQL
          SELECT
            MONTHNAME(t.created_date) AS month,
            COUNT(DISTINCT t.id) AS total, 'Blood film for red cell morphology' AS indicator
          FROM
              tests t
                  INNER JOIN
              test_statuses ts ON ts.test_id = t.id
          WHERE
              t.test_type_id IN #{report_utils.test_type_ids('Manual Differential & Cell Morphology')}
                  AND YEAR(t.created_date) = #{year}
                  AND ts.status_id IN (4 , 5)
                  AND t.voided = 0
          GROUP BY MONTHNAME(t.created_date)
        SQL
      end

      def report_utils
        Reports::Moh::ReportUtils
      end
    end
  end
end
