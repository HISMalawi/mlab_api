# frozen_string_literal: true

# Module defines methods for blood bank generating reports
module Reports
  # Generates blood bank reports
  module Moh
    # bloodbank reports
    class BloodBank < BaseReport
      attr_reader :report, :report_indicator
      attr_accessor :year

      def initialize
        super
        @report = {}
        @report_indicator = REPORT_INDICATORS
        initialize_report_counts
      end

      # rubocop:disable Metrics/AbcSize
      def generate_report
        data = Report.where(year:, name: 'moh_blood_bank').first&.data
        return data if data.present?

        report_data = blood_grouping_on_patient + x_match + x_match_maternity + x_match_paeds +
                      x_match_other + patient_with_hb_greater_6_transfused + patient_with_hb_less_equal_6_transfused +
                      product_results
        data = update_report_counts(report_data)
        Report.find_or_create_by(name: 'moh_blood_bank', year:).update(data:)
        data
      end
      # rubocop:enable Metrics/AbcSize

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
            @report[month_name][indicator.to_sym] = {
              count: 0,
              associated_ids: ''
            }
          end
        end
      end

      def update_report_counts(counts)
        update_report_counts_optimized(counts, 'Blood Bank')
      end

      def blood_grouping_on_patient
        ActiveRecord::Base.connection.execute('SET SESSION group_concat_max_len = 1000000')
        Report.find_by_sql <<~SQL
          SELECT
            MONTHNAME(t.created_date) AS month,
            COUNT(DISTINCT t.id) AS total, 'Blood grouping done on Patients' AS indicator,
            GROUP_CONCAT(DISTINCT t.id) AS associated_ids
          FROM
              tests t
                  INNER JOIN
              test_statuses ts ON ts.test_id = t.id
                        WHERE
              t.test_type_id IN #{GlobalService.fetch_ids(TestType, ['ABO Blood Grouping', 'ABO And RhD Blood Grouping'], ['NLIMS_TT_0029_MWI'])}
                  AND YEAR(t.created_date) = #{year}
                  AND ts.status_id IN (4 , 5)
                  AND t.voided = 0
          GROUP BY MONTHNAME(t.created_date)
        SQL
      end

      def x_match
        ActiveRecord::Base.connection.execute('SET SESSION group_concat_max_len = 1000000')
        Report.find_by_sql <<~SQL
          SELECT
            MONTHNAME(t.created_date) AS month,
            COUNT(DISTINCT t.id) AS total, 'Total X-matched' AS indicator,
            GROUP_CONCAT(DISTINCT t.id) AS associated_ids
          FROM
              tests t
                  INNER JOIN
              test_statuses ts ON ts.test_id = t.id
                        WHERE
              t.test_type_id IN #{GlobalService.fetch_ids(TestType, ['Cross-match'], %w[NLIMS_TT_0030_MWI])}
                  AND YEAR(t.created_date) = #{year}
                  AND ts.status_id IN (4 , 5)
                  AND t.voided = 0
          GROUP BY MONTHNAME(t.created_date)
        SQL
      end

      def x_match_maternity
        ActiveRecord::Base.connection.execute('SET SESSION group_concat_max_len = 1000000')
        Report.find_by_sql <<~SQL
          SELECT
            MONTHNAME(t.created_date) AS month,
            COUNT(DISTINCT t.id) AS total, 'X-matched for matenity' AS indicator,
            GROUP_CONCAT(DISTINCT t.id) AS associated_ids
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
              t.test_type_id IN #{GlobalService.fetch_ids(TestType, ['Cross-match'], %w[NLIMS_TT_0030_MWI])}
                  AND YEAR(t.created_date) = #{year}
                  AND ts.status_id IN (4 , 5)
                  AND t.voided = 0
          GROUP BY MONTHNAME(t.created_date)
        SQL
      end

      def x_match_paeds
        ActiveRecord::Base.connection.execute('SET SESSION group_concat_max_len = 1000000')
        Report.find_by_sql <<~SQL
          SELECT
            MONTHNAME(t.created_date) AS month,
            COUNT(DISTINCT t.id) AS total, 'X-matched for peads' AS indicator,
            GROUP_CONCAT(DISTINCT t.id) AS associated_ids
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
              t.test_type_id IN #{GlobalService.fetch_ids(TestType, ['Cross-match'], %w[NLIMS_TT_0030_MWI])}
                  AND YEAR(t.created_date) = #{year}
                  AND ts.status_id IN (4 , 5)
                  AND t.voided = 0
          GROUP BY MONTHNAME(t.created_date)
        SQL
      end

      def x_match_other
        ActiveRecord::Base.connection.execute('SET SESSION group_concat_max_len = 1000000')
        Report.find_by_sql <<~SQL
          SELECT
            MONTHNAME(t.created_date) AS month,
            COUNT(DISTINCT t.id) AS total, 'X-matched for others' AS indicator,
            GROUP_CONCAT(DISTINCT t.id) AS associated_ids
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
              t.test_type_id IN #{GlobalService.fetch_ids(TestType, ['Cross-match'], %w[NLIMS_TT_0030_MWI])}
                  AND YEAR(t.created_date) = #{year}
                  AND ts.status_id IN (4 , 5)
                  AND t.voided = 0
          GROUP BY MONTHNAME(t.created_date)
        SQL
      end

      def patient_with_hb_less_equal_6_transfused
        ActiveRecord::Base.connection.execute('SET SESSION group_concat_max_len = 1000000')
        Report.find_by_sql <<~SQL
          SELECT
            MONTHNAME(ot.created_date) AS month,
            COUNT(DISTINCT ot.id) AS total,
            'X-matches done on patients with Hb ≤ 6.0g/dl' AS indicator,
            GROUP_CONCAT(DISTINCT ot.id) AS associated_ids
          FROM
              tests ot
                INNER JOIN
              test_type_indicator_mappings ottim ON ottim.test_types_id = ot.test_type_id
                  INNER  JOIN
              test_indicators oti ON oti.id = ottim.test_indicators_id
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
                      test_type_indicator_mappings ttim ON ttim.test_types_id = t.test_type_id
                          INNER  JOIN
                      test_indicators ti ON ti.id = ttim.test_indicators_id
                          INNER JOIN
                      orders o ON o.id = t.order_id
                          INNER JOIN
                      encounters e ON e.id = o.encounter_id
                          INNER JOIN
                      test_results tr ON tr.test_indicator_id = ti.id
                          AND tr.test_id = t.id
                          AND tr.voided = 0
                  WHERE
                      t.test_type_id IN #{GlobalService.fetch_ids(TestType, ['Haemoglobin', 'FBC', 'Full Blood Count'], %w[NLIMS_TT_0035_MWI NLIMS_TT_0105_MWI])}
                          AND ti.id IN #{GlobalService.fetch_ids(TestIndicator, ['Haemoglobin'], %w[NLIMS_TT_0105_MWI])}
                          AND YEAR(t.created_date) = #{year}
                          AND t.status_id IN (4 , 5)
                          AND t.voided = 0
                          AND tr.value <= 6
                          AND tr.value <> ''
                          AND tr.value IS NOT NULL)
                  AND ot.voided = 0
                  AND ot.test_type_id IN #{GlobalService.fetch_ids(TestType, ['Cross-match'], %w[NLIMS_TT_0030_MWI])}
                  AND oti.id IN #{GlobalService.fetch_ids(TestIndicator, ['Pack ABO Group'], %w[NLIMS_TI_0127_MWI])}
                  AND ot.status_id IN (4 , 5)
                  AND YEAR(ot.created_date) = #{year}
          GROUP BY MONTHNAME(ot.created_date)
        SQL
      end

      def patient_with_hb_greater_6_transfused
        ActiveRecord::Base.connection.execute('SET SESSION group_concat_max_len = 1000000')
        Report.find_by_sql <<~SQL
          SELECT
            MONTHNAME(ot.created_date) AS month,
            COUNT(DISTINCT ot.id) AS total,
            'X-matches done on patients with Hb > 6.0 g/dl' AS indicator,
            GROUP_CONCAT(DISTINCT ot.id) AS associated_ids
          FROM
              tests ot
                  INNER JOIN
              test_type_indicator_mappings ottim ON ottim.test_types_id = ot.test_type_id
                  INNER  JOIN
              test_indicators oti ON oti.id = ottim.test_indicators_id
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
                      test_type_indicator_mappings ttim ON ttim.test_types_id = t.test_type_id
                          INNER  JOIN
                      test_indicators ti ON ti.id = ttim.test_indicators_id
                          INNER JOIN
                      orders o ON o.id = t.order_id
                          INNER JOIN
                      encounters e ON e.id = o.encounter_id
                          INNER JOIN
                      test_results tr ON tr.test_indicator_id = ti.id
                          AND tr.test_id = t.id
                          AND tr.voided = 0
                  WHERE
                      t.test_type_id IN #{GlobalService.fetch_ids(TestType, ['Haemoglobin', 'FBC', 'Full Blood Count'], %w[NLIMS_TT_0035_MWI NLIMS_TT_0105_MWI])}
                          AND ti.id IN #{GlobalService.fetch_ids(TestIndicator, ['Haemoglobin'], %w[NLIMS_TT_0105_MWI])}
                          AND YEAR(t.created_date) = #{year}
                          AND t.status_id IN (4 , 5)
                          AND t.voided = 0
                          AND tr.value > 6
                          AND tr.value <> ''
                          AND tr.value IS NOT NULL)
                  AND ot.voided = 0
                  AND ot.test_type_id IN #{GlobalService.fetch_ids(TestType, ['Cross-match'], %w[NLIMS_TT_0030_MWI])}
                  AND oti.id IN #{GlobalService.fetch_ids(TestIndicator, ['Pack ABO Group'], %w[NLIMS_TI_0127_MWI])}
                  AND ot.status_id IN (4 , 5)
                  AND YEAR(ot.created_date) = #{year}
          GROUP BY MONTHNAME(ot.created_date)
        SQL
      end

      def product_results
        ActiveRecord::Base.connection.execute('SET SESSION group_concat_max_len = 1000000')
        Report.find_by_sql <<~SQL
          SELECT
            CASE
                WHEN tr.value = 'FFPs' THEN 'Total Number Transfused with FFP'
                WHEN tr.value = 'Whole Blood' THEN 'Total Number Transfused with Whole blood'
                WHEN tr.value = 'Cryoprecipitate' THEN 'Total Number Transfused with Cryo precipitate'
                WHEN tr.value = 'Platelets' THEN 'Total Number Transfused with Platelets'
                WHEN tr.value IN ('Packed Red Cells' , 'RED BLOOD CELLS') THEN 'Total Number Transfused with Packed Cells'
                ELSE 'other'
            END AS indicator,
            MONTHNAME(t.created_date) AS month,
            COUNT(DISTINCT t.id) AS total,
            GROUP_CONCAT(DISTINCT t.id) AS associated_ids
          FROM
            tests t
                INNER JOIN
            test_type_indicator_mappings ttim ON ttim.test_types_id = t.test_type_id
                INNER  JOIN
            test_indicators ti ON ti.id = ttim.test_indicators_id
                INNER JOIN
            test_results tr ON tr.test_indicator_id = ti.id
                AND tr.test_id = t.id
                AND tr.voided = 0
          WHERE
            t.test_type_id IN #{GlobalService.fetch_ids(TestType, ['Cross-match'], %w[NLIMS_TT_0030_MWI])}
              AND ti.id IN #{GlobalService.fetch_ids(TestIndicator, ['Product Type'], %w[NLIMS_TI_0128_MWI])}
              AND YEAR(t.created_date) =  #{year}
              AND t.status_id IN (4 , 5)
              AND t.voided = 0
              AND tr.value <> ''
              AND tr.value IS NOT NULL
          GROUP BY MONTHNAME(t.created_date), indicator
        SQL
      end

      def report_utils
        Reports::Moh::ReportUtils
      end
    end
  end
end
