# frozen_string_literal: true

# Module defines methods for TB MOH generating reports
module Reports
  # Generates TB MOH reports
  module Moh
    # TB MOH reports
    class TbReport < BaseReport
      attr_reader :report, :report_indicator
      attr_accessor :year

      def initialize
        super
        @report = {}
        @report_indicator = REPORT_INDICATORS
        initialize_report_counts
      end

      def generate_report
        data = Report.where(year:, name: 'tb-report').first&.data
        return data if data.present?

        report_data = total_suspected_tb_samples + total_tb_tests_done + total_1_plus + total_2_plus + total_3_plus +
                      total_follow_ups_2_3_months + total_negative_2_3_months + total_positive_2_3_months +
                      total_follow_ups_5_months + total_negative_5_months + total_positive_5_months +
                      total_follow_ups_6_7_months + total_negative_6_7_months + total_positive_6_7_months +
                      genexpert_total_tests_done + genexpert_male + genexpert_female + genexpert_children +
                      genexpert_reason_male_hospitalized + genexpert_reason_male_presumptive_mdr +
                      genexpert_reason_male_plhiv + genexpert_reason_male_other +
                      genexpert_reason_female_hospitalized + genexpert_reason_female_presumptive_mdr +
                      genexpert_reason_female_plhiv + genexpert_reason_female_other +
                      genexpert_reason_children_hospitalized + genexpert_reason_children_presumptive_mdr +
                      genexpert_reason_children_plhiv + genexpert_reason_children_other +
                      genexpert_total_cartridges +
                      genexpert_mtb_not_detected_male + genexpert_mtb_not_detected_female + genexpert_mtb_not_detected_children +
                      genexpert_mtb_detected_male + genexpert_mtb_detected_female + genexpert_mtb_detected_children +
                      genexpert_rif_detected_male + genexpert_rif_detected_female + genexpert_rif_detected_children +
                      genexpert_indeterminate + genexpert_total_errors + genexpert_no_results
        data = update_report_counts(report_data)
        Report.find_or_create_by(name: 'tb-report', year:).update(data:)
        data
      end

      private

      REPORT_INDICATORS = [
        'Total Number of cases',
        'Total Number of Microscopy Tests done',
        'Microscopy 1+',
        'Microscopy 2+',
        'Microscopy 3+',
        'Pick-up rate',
        'Total Follow ups 2/3 months',
        'Total Negative Microscopy 2/3 months',
        'Total Positive Microscopy 2/3 months',
        'Total Follow ups 5 months',
        'Total Negative Microscopy 5 months',
        'Total Positive Microscopy 5 months',
        'Total Follow ups 6/7 months',
        'Total Negative Microscopy 6/7 months',
        'Total Positive Microscopy 6/7 months',
        'GeneXpert Total tests done',
        'GeneXpert Male',
        'GeneXpert Female',
        'GeneXpert Children',
        'GeneXpert Reason Male Hospitalized',
        'GeneXpert Reason Male Presumptive MDR',
        'GeneXpert Reason Male PLHIV',
        'GeneXpert Reason Male Other Risk Groups',
        'GeneXpert Reason Female Hospitalized',
        'GeneXpert Reason Female Presumptive MDR',
        'GeneXpert Reason Female PLHIV',
        'GeneXpert Reason Female Other Risk Groups',
        'GeneXpert Reason Children Hospitalized',
        'GeneXpert Reason Children Presumptive MDR',
        'GeneXpert Reason Children PLHIV',
        'GeneXpert Reason Children Other Risk Groups',
        'GeneXpert Total cartridges used',
        'GeneXpert MTB not detected Male',
        'GeneXpert MTB not detected Female',
        'GeneXpert MTB not detected Children',
        'GeneXpert MTB detected Male',
        'GeneXpert MTB detected Female',
        'GeneXpert MTB detected Children',
        'GeneXpert RIF detected Male',
        'GeneXpert RIF detected Female',
        'GeneXpert RIF detected Children',
        'GeneXpert Positivity Rate',
        'GeneXpert Indeterminate',
        'GeneXpert Total Errors',
        'GeneXpert Error Rate',
        'GeneXpert No Results'
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
        update_report_counts_optimized(counts, 'TB Report')
      end

      # Total number of Suspected TB Test samples (samples registered for tb testing)
      def total_suspected_tb_samples
        ActiveRecord::Base.connection.execute('SET SESSION group_concat_max_len = 1000000')
        Report.find_by_sql <<~SQL
          SELECT
            MONTHNAME(t.created_date) AS month,
            COUNT(DISTINCT t.id) AS total,
            'Total Number of cases' AS indicator,
            GROUP_CONCAT(DISTINCT t.id) AS associated_ids
          FROM
              tests t
          WHERE
              t.test_type_id IN #{GlobalService.fetch_ids(TestType, ['TB Tests'], ['NLIMS_TT_0010_MWI'])}
              AND YEAR(t.created_date) = #{year}
              AND t.voided = 0
          GROUP BY MONTHNAME(t.created_date)
        SQL
      end

      # Total number of TB tests completed/done
      def total_tb_tests_done
        ActiveRecord::Base.connection.execute('SET SESSION group_concat_max_len = 1000000')
        Report.find_by_sql <<~SQL
          SELECT
            MONTHNAME(t.created_date) AS month,
            COUNT(DISTINCT t.id) AS total,
            'Total Number of Microscopy Tests done' AS indicator,
            GROUP_CONCAT(DISTINCT t.id) AS associated_ids
          FROM
              tests t
                  INNER JOIN
              test_type_indicator_mappings ttim ON ttim.test_types_id = t.test_type_id
                  INNER JOIN
              test_indicators ti ON ti.id = ttim.test_indicators_id
                  INNER JOIN
              test_results tr ON tr.test_indicator_id = ti.id
                  AND tr.test_id = t.id
                  AND tr.voided = 0
          WHERE
              t.test_type_id IN #{GlobalService.fetch_ids(TestType, ['TB Tests'], ['NLIMS_TT_0010_MWI'])}
              AND ti.id IN #{GlobalService.fetch_ids(TestIndicator, ['Smear Microscopy', 'Smear microscopy result'], ['NLIMS_TI_0201_MWI'])}
              AND YEAR(t.created_date) = #{year}
              AND t.status_id IN (4, 5)
              AND t.voided = 0
              AND tr.value NOT IN ('', '0')
              AND tr.value IS NOT NULL
          GROUP BY MONTHNAME(t.created_date)
        SQL
      end

      # Total number of positive TB tests completed/done with 1+ positive result
      def total_1_plus
        ActiveRecord::Base.connection.execute('SET SESSION group_concat_max_len = 1000000')
        Report.find_by_sql <<~SQL
          SELECT
            MONTHNAME(t.created_date) AS month,
            COUNT(DISTINCT t.id) AS total,
            'Microscopy 1+' AS indicator,
            GROUP_CONCAT(DISTINCT t.id) AS associated_ids
          FROM
              tests t
                  INNER JOIN
              test_type_indicator_mappings ttim ON ttim.test_types_id = t.test_type_id
                  INNER JOIN
              test_indicators ti ON ti.id = ttim.test_indicators_id
                  INNER JOIN
              test_results tr ON tr.test_indicator_id = ti.id
                  AND tr.test_id = t.id
                  AND tr.voided = 0
          WHERE
              t.test_type_id IN #{GlobalService.fetch_ids(TestType, ['TB Tests'], ['NLIMS_TT_0010_MWI'])}
              AND ti.id IN #{GlobalService.fetch_ids(TestIndicator, ['Smear Microscopy', 'Smear microscopy result'], ['NLIMS_TI_0201_MWI'])}
              AND YEAR(t.created_date) = #{year}
              AND t.status_id IN (4, 5)
              AND t.voided = 0
              AND tr.value LIKE '1+%'
          GROUP BY MONTHNAME(t.created_date)
        SQL
      end

      # Total number of positive TB tests completed/done with 2+ positive result
      def total_2_plus
        ActiveRecord::Base.connection.execute('SET SESSION group_concat_max_len = 1000000')
        Report.find_by_sql <<~SQL
          SELECT
            MONTHNAME(t.created_date) AS month,
            COUNT(DISTINCT t.id) AS total,
            'Microscopy 2+' AS indicator,
            GROUP_CONCAT(DISTINCT t.id) AS associated_ids
          FROM
              tests t
                  INNER JOIN
              test_type_indicator_mappings ttim ON ttim.test_types_id = t.test_type_id
                  INNER JOIN
              test_indicators ti ON ti.id = ttim.test_indicators_id
                  INNER JOIN
              test_results tr ON tr.test_indicator_id = ti.id
                  AND tr.test_id = t.id
                  AND tr.voided = 0
          WHERE
              t.test_type_id IN #{GlobalService.fetch_ids(TestType, ['TB Tests'], ['NLIMS_TT_0010_MWI'])}
              AND ti.id IN #{GlobalService.fetch_ids(TestIndicator, ['Smear Microscopy', 'Smear microscopy result'], ['NLIMS_TI_0201_MWI'])}
              AND YEAR(t.created_date) = #{year}
              AND t.status_id IN (4, 5)
              AND t.voided = 0
              AND tr.value LIKE '2+%'
          GROUP BY MONTHNAME(t.created_date)
        SQL
      end

      # Total number of positive TB tests completed/done with 3+ positive result
      def total_3_plus
        ActiveRecord::Base.connection.execute('SET SESSION group_concat_max_len = 1000000')
        Report.find_by_sql <<~SQL
          SELECT
            MONTHNAME(t.created_date) AS month,
            COUNT(DISTINCT t.id) AS total,
            'Microscopy 3+' AS indicator,
            GROUP_CONCAT(DISTINCT t.id) AS associated_ids
          FROM
              tests t
                  INNER JOIN
              test_type_indicator_mappings ttim ON ttim.test_types_id = t.test_type_id
                  INNER JOIN
              test_indicators ti ON ti.id = ttim.test_indicators_id
                  INNER JOIN
              test_results tr ON tr.test_indicator_id = ti.id
                  AND tr.test_id = t.id
                  AND tr.voided = 0
          WHERE
              t.test_type_id IN #{GlobalService.fetch_ids(TestType, ['TB Tests'], ['NLIMS_TT_0010_MWI'])}
              AND ti.id IN #{GlobalService.fetch_ids(TestIndicator, ['Smear Microscopy', 'Smear microscopy result'], ['NLIMS_TI_0201_MWI'])}
              AND YEAR(t.created_date) = #{year}
              AND t.status_id IN (4, 5)
              AND t.voided = 0
              AND tr.value LIKE '3+%'
          GROUP BY MONTHNAME(t.created_date)
        SQL
      end

      # Total number of follow up tb tests done within 2 to 3 months (completed)
      def total_follow_ups_2_3_months
        ActiveRecord::Base.connection.execute('SET SESSION group_concat_max_len = 1000000')
        Report.find_by_sql <<~SQL
          SELECT
            MONTHNAME(t2.created_date) AS month,
            COUNT(DISTINCT t2.id) AS total,
            'Total Follow ups 2/3 months' AS indicator,
            GROUP_CONCAT(DISTINCT t2.id) AS associated_ids
          FROM
              tests t1
                  INNER JOIN orders o1 ON o1.id = t1.order_id
                  INNER JOIN encounters e1 ON e1.id = o1.encounter_id
                  INNER JOIN tests t2 ON t2.id != t1.id
                  INNER JOIN orders o2 ON o2.id = t2.order_id
                  INNER JOIN encounters e2 ON e2.id = o2.encounter_id AND e2.client_id = e1.client_id
          WHERE
              t1.test_type_id IN #{GlobalService.fetch_ids(TestType, ['TB Tests'], ['NLIMS_TT_0010_MWI'])}
              AND t2.test_type_id IN #{GlobalService.fetch_ids(TestType, ['TB Tests'], ['NLIMS_TT_0010_MWI'])}
              AND YEAR(t2.created_date) = #{year}
              AND t2.status_id IN (4, 5)
              AND t2.voided = 0
              AND t1.voided = 0
              AND DATEDIFF(t2.created_date, t1.created_date) BETWEEN 60 AND 90
              AND t2.created_date > t1.created_date
          GROUP BY MONTHNAME(t2.created_date)
        SQL
      end

      # Total number of negative microscopy tb tests (completed within 2 to 3 months)
      def total_negative_2_3_months
        ActiveRecord::Base.connection.execute('SET SESSION group_concat_max_len = 1000000')
        Report.find_by_sql <<~SQL
          SELECT
            MONTHNAME(t2.created_date) AS month,
            COUNT(DISTINCT t2.id) AS total,
            'Total Negative Microscopy 2/3 months' AS indicator,
            GROUP_CONCAT(DISTINCT t2.id) AS associated_ids
          FROM
              tests t1
                  INNER JOIN orders o1 ON o1.id = t1.order_id
                  INNER JOIN encounters e1 ON e1.id = o1.encounter_id
                  INNER JOIN tests t2 ON t2.id != t1.id
                  INNER JOIN orders o2 ON o2.id = t2.order_id
                  INNER JOIN encounters e2 ON e2.id = o2.encounter_id AND e2.client_id = e1.client_id
                  INNER JOIN test_type_indicator_mappings ttim ON ttim.test_types_id = t2.test_type_id
                  INNER JOIN test_indicators ti ON ti.id = ttim.test_indicators_id
                  INNER JOIN test_results tr ON tr.test_indicator_id = ti.id
                      AND tr.test_id = t2.id
                      AND tr.voided = 0
          WHERE
              t1.test_type_id IN #{GlobalService.fetch_ids(TestType, ['TB Tests'], ['NLIMS_TT_0010_MWI'])}
              AND t2.test_type_id IN #{GlobalService.fetch_ids(TestType, ['TB Tests'], ['NLIMS_TT_0010_MWI'])}
              AND ti.id IN #{GlobalService.fetch_ids(TestIndicator, ['Smear Microscopy', 'Smear microscopy result'], ['NLIMS_TI_0201_MWI'])}
              AND YEAR(t2.created_date) = #{year}
              AND t2.status_id IN (4, 5)
              AND t2.voided = 0
              AND t1.voided = 0
              AND DATEDIFF(t2.created_date, t1.created_date) BETWEEN 60 AND 90
              AND t2.created_date > t1.created_date
              AND tr.value LIKE '%Negative%'
          GROUP BY MONTHNAME(t2.created_date)
        SQL
      end

      # Total number of 1+, 2+, 3+ or Scanty results for TB tests within 2 to 3 months
      def total_positive_2_3_months
        ActiveRecord::Base.connection.execute('SET SESSION group_concat_max_len = 1000000')
        Report.find_by_sql <<~SQL
          SELECT
            MONTHNAME(t2.created_date) AS month,
            COUNT(DISTINCT t2.id) AS total,
            'Total Positive Microscopy 2/3 months' AS indicator,
            GROUP_CONCAT(DISTINCT t2.id) AS associated_ids
          FROM
              tests t1
                  INNER JOIN orders o1 ON o1.id = t1.order_id
                  INNER JOIN encounters e1 ON e1.id = o1.encounter_id
                  INNER JOIN tests t2 ON t2.id != t1.id
                  INNER JOIN orders o2 ON o2.id = t2.order_id
                  INNER JOIN encounters e2 ON e2.id = o2.encounter_id AND e2.client_id = e1.client_id
                  INNER JOIN test_type_indicator_mappings ttim ON ttim.test_types_id = t2.test_type_id
                  INNER JOIN test_indicators ti ON ti.id = ttim.test_indicators_id
                  INNER JOIN test_results tr ON tr.test_indicator_id = ti.id
                      AND tr.test_id = t2.id
                      AND tr.voided = 0
          WHERE
              t1.test_type_id IN #{GlobalService.fetch_ids(TestType, ['TB Tests'], ['NLIMS_TT_0010_MWI'])}
              AND t2.test_type_id IN #{GlobalService.fetch_ids(TestType, ['TB Tests'], ['NLIMS_TT_0010_MWI'])}
              AND ti.id IN #{GlobalService.fetch_ids(TestIndicator, ['Smear Microscopy', 'Smear microscopy result'], ['NLIMS_TI_0201_MWI'])}
              AND YEAR(t2.created_date) = #{year}
              AND t2.status_id IN (4, 5)
              AND t2.voided = 0
              AND t1.voided = 0
              AND DATEDIFF(t2.created_date, t1.created_date) BETWEEN 60 AND 90
              AND t2.created_date > t1.created_date
              AND (tr.value LIKE '%+%' OR tr.value LIKE '%Scanty%')
          GROUP BY MONTHNAME(t2.created_date)
        SQL
      end

      # Total number of follow up tb tests done after 5 months (completed)
      def total_follow_ups_5_months
        ActiveRecord::Base.connection.execute('SET SESSION group_concat_max_len = 1000000')
        Report.find_by_sql <<~SQL
          SELECT
            MONTHNAME(t2.created_date) AS month,
            COUNT(DISTINCT t2.id) AS total,
            'Total Follow ups 5 months' AS indicator,
            GROUP_CONCAT(DISTINCT t2.id) AS associated_ids
          FROM
              tests t1
                  INNER JOIN orders o1 ON o1.id = t1.order_id
                  INNER JOIN encounters e1 ON e1.id = o1.encounter_id
                  INNER JOIN tests t2 ON t2.id != t1.id
                  INNER JOIN orders o2 ON o2.id = t2.order_id
                  INNER JOIN encounters e2 ON e2.id = o2.encounter_id AND e2.client_id = e1.client_id
          WHERE
              t1.test_type_id IN #{GlobalService.fetch_ids(TestType, ['TB Tests'], ['NLIMS_TT_0010_MWI'])}
              AND t2.test_type_id IN #{GlobalService.fetch_ids(TestType, ['TB Tests'], ['NLIMS_TT_0010_MWI'])}
              AND YEAR(t2.created_date) = #{year}
              AND t2.status_id IN (4, 5)
              AND t2.voided = 0
              AND t1.voided = 0
              AND DATEDIFF(t2.created_date, t1.created_date) >= 150
              AND t2.created_date > t1.created_date
          GROUP BY MONTHNAME(t2.created_date)
        SQL
      end

      # Total number of negative microscopy tb tests (completed after 5 months)
      def total_negative_5_months
        ActiveRecord::Base.connection.execute('SET SESSION group_concat_max_len = 1000000')
        Report.find_by_sql <<~SQL
          SELECT
            MONTHNAME(t2.created_date) AS month,
            COUNT(DISTINCT t2.id) AS total,
            'Total Negative Microscopy 5 months' AS indicator,
            GROUP_CONCAT(DISTINCT t2.id) AS associated_ids
          FROM
              tests t1
                  INNER JOIN orders o1 ON o1.id = t1.order_id
                  INNER JOIN encounters e1 ON e1.id = o1.encounter_id
                  INNER JOIN tests t2 ON t2.id != t1.id
                  INNER JOIN orders o2 ON o2.id = t2.order_id
                  INNER JOIN encounters e2 ON e2.id = o2.encounter_id AND e2.client_id = e1.client_id
                  INNER JOIN test_type_indicator_mappings ttim ON ttim.test_types_id = t2.test_type_id
                  INNER JOIN test_indicators ti ON ti.id = ttim.test_indicators_id
                  INNER JOIN test_results tr ON tr.test_indicator_id = ti.id
                      AND tr.test_id = t2.id
                      AND tr.voided = 0
          WHERE
              t1.test_type_id IN #{GlobalService.fetch_ids(TestType, ['TB Tests'], ['NLIMS_TT_0010_MWI'])}
              AND t2.test_type_id IN #{GlobalService.fetch_ids(TestType, ['TB Tests'], ['NLIMS_TT_0010_MWI'])}
              AND ti.id IN #{GlobalService.fetch_ids(TestIndicator, ['Smear Microscopy', 'Smear microscopy result'], ['NLIMS_TI_0201_MWI'])}
              AND YEAR(t2.created_date) = #{year}
              AND t2.status_id IN (4, 5)
              AND t2.voided = 0
              AND t1.voided = 0
              AND DATEDIFF(t2.created_date, t1.created_date) >= 150
              AND t2.created_date > t1.created_date
              AND tr.value LIKE '%Negative%'
          GROUP BY MONTHNAME(t2.created_date)
        SQL
      end

      # Total number of 1+, 2+, 3+ or Scanty results for TB tests after 5 months
      def total_positive_5_months
        ActiveRecord::Base.connection.execute('SET SESSION group_concat_max_len = 1000000')
        Report.find_by_sql <<~SQL
          SELECT
            MONTHNAME(t2.created_date) AS month,
            COUNT(DISTINCT t2.id) AS total,
            'Total Positive Microscopy 5 months' AS indicator,
            GROUP_CONCAT(DISTINCT t2.id) AS associated_ids
          FROM
              tests t1
                  INNER JOIN orders o1 ON o1.id = t1.order_id
                  INNER JOIN encounters e1 ON e1.id = o1.encounter_id
                  INNER JOIN tests t2 ON t2.id != t1.id
                  INNER JOIN orders o2 ON o2.id = t2.order_id
                  INNER JOIN encounters e2 ON e2.id = o2.encounter_id AND e2.client_id = e1.client_id
                  INNER JOIN test_type_indicator_mappings ttim ON ttim.test_types_id = t2.test_type_id
                  INNER JOIN test_indicators ti ON ti.id = ttim.test_indicators_id
                  INNER JOIN test_results tr ON tr.test_indicator_id = ti.id
                      AND tr.test_id = t2.id
                      AND tr.voided = 0
          WHERE
              t1.test_type_id IN #{GlobalService.fetch_ids(TestType, ['TB Tests'], ['NLIMS_TT_0010_MWI'])}
              AND t2.test_type_id IN #{GlobalService.fetch_ids(TestType, ['TB Tests'], ['NLIMS_TT_0010_MWI'])}
              AND ti.id IN #{GlobalService.fetch_ids(TestIndicator, ['Smear Microscopy', 'Smear microscopy result'], ['NLIMS_TI_0201_MWI'])}
              AND YEAR(t2.created_date) = #{year}
              AND t2.status_id IN (4, 5)
              AND t2.voided = 0
              AND t1.voided = 0
              AND DATEDIFF(t2.created_date, t1.created_date) >= 150
              AND t2.created_date > t1.created_date
              AND (tr.value LIKE '%+%' OR tr.value LIKE '%Scanty%')
          GROUP BY MONTHNAME(t2.created_date)
        SQL
      end

      # Total number of follow up tb tests done within 6 to 7 months (completed)
      def total_follow_ups_6_7_months
        ActiveRecord::Base.connection.execute('SET SESSION group_concat_max_len = 1000000')
        Report.find_by_sql <<~SQL
          SELECT
            MONTHNAME(t2.created_date) AS month,
            COUNT(DISTINCT t2.id) AS total,
            'Total Follow ups 6/7 months' AS indicator,
            GROUP_CONCAT(DISTINCT t2.id) AS associated_ids
          FROM
              tests t1
                  INNER JOIN orders o1 ON o1.id = t1.order_id
                  INNER JOIN encounters e1 ON e1.id = o1.encounter_id
                  INNER JOIN tests t2 ON t2.id != t1.id
                  INNER JOIN orders o2 ON o2.id = t2.order_id
                  INNER JOIN encounters e2 ON e2.id = o2.encounter_id AND e2.client_id = e1.client_id
          WHERE
              t1.test_type_id IN #{GlobalService.fetch_ids(TestType, ['TB Tests'], ['NLIMS_TT_0010_MWI'])}
              AND t2.test_type_id IN #{GlobalService.fetch_ids(TestType, ['TB Tests'], ['NLIMS_TT_0010_MWI'])}
              AND YEAR(t2.created_date) = #{year}
              AND t2.status_id IN (4, 5)
              AND t2.voided = 0
              AND t1.voided = 0
              AND DATEDIFF(t2.created_date, t1.created_date) BETWEEN 180 AND 210
              AND t2.created_date > t1.created_date
          GROUP BY MONTHNAME(t2.created_date)
        SQL
      end

      # Total number of negative microscopy tb tests (completed within 6 to 7 months)
      def total_negative_6_7_months
        ActiveRecord::Base.connection.execute('SET SESSION group_concat_max_len = 1000000')
        Report.find_by_sql <<~SQL
          SELECT
            MONTHNAME(t2.created_date) AS month,
            COUNT(DISTINCT t2.id) AS total,
            'Total Negative Microscopy 6/7 months' AS indicator,
            GROUP_CONCAT(DISTINCT t2.id) AS associated_ids
          FROM
              tests t1
                  INNER JOIN orders o1 ON o1.id = t1.order_id
                  INNER JOIN encounters e1 ON e1.id = o1.encounter_id
                  INNER JOIN tests t2 ON t2.id != t1.id
                  INNER JOIN orders o2 ON o2.id = t2.order_id
                  INNER JOIN encounters e2 ON e2.id = o2.encounter_id AND e2.client_id = e1.client_id
                  INNER JOIN test_type_indicator_mappings ttim ON ttim.test_types_id = t2.test_type_id
                  INNER JOIN test_indicators ti ON ti.id = ttim.test_indicators_id
                  INNER JOIN test_results tr ON tr.test_indicator_id = ti.id
                      AND tr.test_id = t2.id
                      AND tr.voided = 0
          WHERE
              t1.test_type_id IN #{GlobalService.fetch_ids(TestType, ['TB Tests'], ['NLIMS_TT_0010_MWI'])}
              AND t2.test_type_id IN #{GlobalService.fetch_ids(TestType, ['TB Tests'], ['NLIMS_TT_0010_MWI'])}
              AND ti.id IN #{GlobalService.fetch_ids(TestIndicator, ['Smear Microscopy', 'Smear microscopy result'], ['NLIMS_TI_0201_MWI'])}
              AND YEAR(t2.created_date) = #{year}
              AND t2.status_id IN (4, 5)
              AND t2.voided = 0
              AND t1.voided = 0
              AND DATEDIFF(t2.created_date, t1.created_date) BETWEEN 180 AND 210
              AND t2.created_date > t1.created_date
              AND tr.value LIKE '%Negative%'
          GROUP BY MONTHNAME(t2.created_date)
        SQL
      end

      # Total number of 1+, 2+, 3+ or Scanty results for TB tests within 6 to 7 months
      def total_positive_6_7_months
        ActiveRecord::Base.connection.execute('SET SESSION group_concat_max_len = 1000000')
        Report.find_by_sql <<~SQL
          SELECT
            MONTHNAME(t2.created_date) AS month,
            COUNT(DISTINCT t2.id) AS total,
            'Total Positive Microscopy 6/7 months' AS indicator,
            GROUP_CONCAT(DISTINCT t2.id) AS associated_ids
          FROM
              tests t1
                  INNER JOIN orders o1 ON o1.id = t1.order_id
                  INNER JOIN encounters e1 ON e1.id = o1.encounter_id
                  INNER JOIN tests t2 ON t2.id != t1.id
                  INNER JOIN orders o2 ON o2.id = t2.order_id
                  INNER JOIN encounters e2 ON e2.id = o2.encounter_id AND e2.client_id = e1.client_id
                  INNER JOIN test_type_indicator_mappings ttim ON ttim.test_types_id = t2.test_type_id
                  INNER JOIN test_indicators ti ON ti.id = ttim.test_indicators_id
                  INNER JOIN test_results tr ON tr.test_indicator_id = ti.id
                      AND tr.test_id = t2.id
                      AND tr.voided = 0
          WHERE
              t1.test_type_id IN #{GlobalService.fetch_ids(TestType, ['TB Tests'], ['NLIMS_TT_0010_MWI'])}
              AND t2.test_type_id IN #{GlobalService.fetch_ids(TestType, ['TB Tests'], ['NLIMS_TT_0010_MWI'])}
              AND ti.id IN #{GlobalService.fetch_ids(TestIndicator, ['Smear Microscopy', 'Smear microscopy result'], ['NLIMS_TI_0201_MWI'])}
              AND YEAR(t2.created_date) = #{year}
              AND t2.status_id IN (4, 5)
              AND t2.voided = 0
              AND t1.voided = 0
              AND DATEDIFF(t2.created_date, t1.created_date) BETWEEN 180 AND 210
              AND t2.created_date > t1.created_date
              AND (tr.value LIKE '%+%' OR tr.value LIKE '%Scanty%')
          GROUP BY MONTHNAME(t2.created_date)
        SQL
      end

      # GeneXpert MTB/RIF - Total tests done
      def genexpert_total_tests_done
        ActiveRecord::Base.connection.execute('SET SESSION group_concat_max_len = 1000000')
        Report.find_by_sql <<~SQL
          SELECT
            MONTHNAME(t.created_date) AS month,
            COUNT(DISTINCT t.id) AS total,
            'GeneXpert Total tests done' AS indicator,
            GROUP_CONCAT(DISTINCT t.id) AS associated_ids
          FROM
              tests t
                  INNER JOIN test_type_indicator_mappings ttim ON ttim.test_types_id = t.test_type_id
                  INNER JOIN test_indicators ti ON ti.id = ttim.test_indicators_id
                  INNER JOIN test_results tr ON tr.test_indicator_id = ti.id
                      AND tr.test_id = t.id
                      AND tr.voided = 0
          WHERE
              t.test_type_id IN #{GlobalService.fetch_ids(TestType, ['TB Tests'], ['NLIMS_TT_0010_MWI'])}
              AND ti.id IN #{GlobalService.fetch_ids(TestIndicator, ['Gene Xpert MTB'], ['NLIMS_TI_0202_MWI'])}
              AND YEAR(t.created_date) = #{year}
              AND t.status_id IN (4, 5)
              AND t.voided = 0
          GROUP BY MONTHNAME(t.created_date)
        SQL
      end

      # GeneXpert MTB/RIF - Male
      def genexpert_male
        ActiveRecord::Base.connection.execute('SET SESSION group_concat_max_len = 1000000')
        Report.find_by_sql <<~SQL
          SELECT
            MONTHNAME(t.created_date) AS month,
            COUNT(DISTINCT t.id) AS total,
            'GeneXpert Male' AS indicator,
            GROUP_CONCAT(DISTINCT t.id) AS associated_ids
          FROM
              tests t
                  INNER JOIN orders o ON o.id = t.order_id
                  INNER JOIN encounters e ON e.id = o.encounter_id
                  INNER JOIN clients c ON c.id = e.client_id
                  INNER JOIN people p ON p.id = c.person_id
                  INNER JOIN test_type_indicator_mappings ttim ON ttim.test_types_id = t.test_type_id
                  INNER JOIN test_indicators ti ON ti.id = ttim.test_indicators_id
                  INNER JOIN test_results tr ON tr.test_indicator_id = ti.id
                      AND tr.test_id = t.id
                      AND tr.voided = 0
          WHERE
              t.test_type_id IN #{GlobalService.fetch_ids(TestType, ['TB Tests'], ['NLIMS_TT_0010_MWI'])}
              AND ti.id IN #{GlobalService.fetch_ids(TestIndicator, ['Gene Xpert MTB'], ['NLIMS_TI_0202_MWI'])}
              AND YEAR(t.created_date) = #{year}
              AND t.status_id IN (4, 5)
              AND t.voided = 0
              AND p.sex = 'M'
          GROUP BY MONTHNAME(t.created_date)
        SQL
      end

      # GeneXpert MTB/RIF - Female
      def genexpert_female
        ActiveRecord::Base.connection.execute('SET SESSION group_concat_max_len = 1000000')
        Report.find_by_sql <<~SQL
          SELECT
            MONTHNAME(t.created_date) AS month,
            COUNT(DISTINCT t.id) AS total,
            'GeneXpert Female' AS indicator,
            GROUP_CONCAT(DISTINCT t.id) AS associated_ids
          FROM
              tests t
                  INNER JOIN orders o ON o.id = t.order_id
                  INNER JOIN encounters e ON e.id = o.encounter_id
                  INNER JOIN clients c ON c.id = e.client_id
                  INNER JOIN people p ON p.id = c.person_id
                  INNER JOIN test_type_indicator_mappings ttim ON ttim.test_types_id = t.test_type_id
                  INNER JOIN test_indicators ti ON ti.id = ttim.test_indicators_id
                  INNER JOIN test_results tr ON tr.test_indicator_id = ti.id
                      AND tr.test_id = t.id
                      AND tr.voided = 0
          WHERE
              t.test_type_id IN #{GlobalService.fetch_ids(TestType, ['TB Tests'], ['NLIMS_TT_0010_MWI'])}
              AND ti.id IN #{GlobalService.fetch_ids(TestIndicator, ['Gene Xpert MTB'], ['NLIMS_TI_0202_MWI'])}
              AND YEAR(t.created_date) = #{year}
              AND t.status_id IN (4, 5)
              AND t.voided = 0
              AND p.sex = 'F'
          GROUP BY MONTHNAME(t.created_date)
        SQL
      end

      # GeneXpert MTB/RIF - Children (12 and below)
      def genexpert_children
        ActiveRecord::Base.connection.execute('SET SESSION group_concat_max_len = 1000000')
        Report.find_by_sql <<~SQL
          SELECT
            MONTHNAME(t.created_date) AS month,
            COUNT(DISTINCT t.id) AS total,
            'GeneXpert Children' AS indicator,
            GROUP_CONCAT(DISTINCT t.id) AS associated_ids
          FROM
              tests t
                  INNER JOIN orders o ON o.id = t.order_id
                  INNER JOIN encounters e ON e.id = o.encounter_id
                  INNER JOIN clients c ON c.id = e.client_id
                  INNER JOIN people p ON p.id = c.person_id
                  INNER JOIN test_type_indicator_mappings ttim ON ttim.test_types_id = t.test_type_id
                  INNER JOIN test_indicators ti ON ti.id = ttim.test_indicators_id
                  INNER JOIN test_results tr ON tr.test_indicator_id = ti.id
                      AND tr.test_id = t.id
                      AND tr.voided = 0
          WHERE
              t.test_type_id IN #{GlobalService.fetch_ids(TestType, ['TB Tests'], ['NLIMS_TT_0010_MWI'])}
              AND ti.id IN #{GlobalService.fetch_ids(TestIndicator, ['Gene Xpert MTB'], ['NLIMS_TI_0202_MWI'])}
              AND YEAR(t.created_date) = #{year}
              AND t.status_id IN (4, 5)
              AND t.voided = 0
              AND TIMESTAMPDIFF(YEAR, p.date_of_birth, t.created_date) <= 12
          GROUP BY MONTHNAME(t.created_date)
        SQL
      end

      # GeneXpert Reason Male Hospitalized
      def genexpert_reason_male_hospitalized
        ActiveRecord::Base.connection.execute('SET SESSION group_concat_max_len = 1000000')
        Report.find_by_sql <<~SQL
          SELECT
            MONTHNAME(t.created_date) AS month,
            COUNT(DISTINCT t.id) AS total,
            'GeneXpert Reason Male Hospitalized' AS indicator,
            GROUP_CONCAT(DISTINCT t.id) AS associated_ids
          FROM
              tests t
                  INNER JOIN orders o ON o.id = t.order_id
                  INNER JOIN encounters e ON e.id = o.encounter_id
                  INNER JOIN clients c ON c.id = e.client_id
                  INNER JOIN people p ON p.id = c.person_id
                  INNER JOIN test_type_indicator_mappings ttim ON ttim.test_types_id = t.test_type_id
                  INNER JOIN test_indicators ti ON ti.id = ttim.test_indicators_id
                  INNER JOIN test_results tr ON tr.test_indicator_id = ti.id
                      AND tr.test_id = t.id
                      AND tr.voided = 0
          WHERE
              t.test_type_id IN #{GlobalService.fetch_ids(TestType, ['TB Tests'], ['NLIMS_TT_0010_MWI'])}
              AND ti.id IN #{GlobalService.fetch_ids(TestIndicator, ['Reason For Testing'], ['NLIMS_TI_0233_MWI'])}
              AND t.id IN (
                  SELECT DISTINCT t2.id FROM tests t2
                  INNER JOIN test_type_indicator_mappings ttim2 ON ttim2.test_types_id = t2.test_type_id
                  INNER JOIN test_indicators ti2 ON ti2.id = ttim2.test_indicators_id
                  INNER JOIN test_results tr2 ON tr2.test_indicator_id = ti2.id AND tr2.test_id = t2.id AND tr2.voided = 0
                  WHERE ti2.id IN #{GlobalService.fetch_ids(TestIndicator, ['Gene Xpert MTB'], ['NLIMS_TI_0202_MWI'])}
              )
              AND YEAR(t.created_date) = #{year}
              AND t.status_id IN (4, 5)
              AND t.voided = 0
              AND p.sex = 'M'
              AND tr.value LIKE '%Hospitalized%'
          GROUP BY MONTHNAME(t.created_date)
        SQL
      end

      # GeneXpert Reason Male Presumptive MDR
      def genexpert_reason_male_presumptive_mdr
        ActiveRecord::Base.connection.execute('SET SESSION group_concat_max_len = 1000000')
        Report.find_by_sql <<~SQL
          SELECT
            MONTHNAME(t.created_date) AS month,
            COUNT(DISTINCT t.id) AS total,
            'GeneXpert Reason Male Presumptive MDR' AS indicator,
            GROUP_CONCAT(DISTINCT t.id) AS associated_ids
          FROM
              tests t
                  INNER JOIN orders o ON o.id = t.order_id
                  INNER JOIN encounters e ON e.id = o.encounter_id
                  INNER JOIN clients c ON c.id = e.client_id
                  INNER JOIN people p ON p.id = c.person_id
                  INNER JOIN test_type_indicator_mappings ttim ON ttim.test_types_id = t.test_type_id
                  INNER JOIN test_indicators ti ON ti.id = ttim.test_indicators_id
                  INNER JOIN test_results tr ON tr.test_indicator_id = ti.id
                      AND tr.test_id = t.id
                      AND tr.voided = 0
          WHERE
              t.test_type_id IN #{GlobalService.fetch_ids(TestType, ['TB Tests'], ['NLIMS_TT_0010_MWI'])}
              AND ti.id IN #{GlobalService.fetch_ids(TestIndicator, ['Reason For Testing'], ['NLIMS_TI_0233_MWI'])}
              AND t.id IN (
                  SELECT DISTINCT t2.id FROM tests t2
                  INNER JOIN test_type_indicator_mappings ttim2 ON ttim2.test_types_id = t2.test_type_id
                  INNER JOIN test_indicators ti2 ON ti2.id = ttim2.test_indicators_id
                  INNER JOIN test_results tr2 ON tr2.test_indicator_id = ti2.id AND tr2.test_id = t2.id AND tr2.voided = 0
                  WHERE ti2.id IN #{GlobalService.fetch_ids(TestIndicator, ['Gene Xpert MTB'], ['NLIMS_TI_0202_MWI'])}
              )
              AND YEAR(t.created_date) = #{year}
              AND t.status_id IN (4, 5)
              AND t.voided = 0
              AND p.sex = 'M'
              AND tr.value LIKE '%Presumptive MDR%'
          GROUP BY MONTHNAME(t.created_date)
        SQL
      end

      # GeneXpert Reason Male PLHIV
      def genexpert_reason_male_plhiv
        ActiveRecord::Base.connection.execute('SET SESSION group_concat_max_len = 1000000')
        Report.find_by_sql <<~SQL
          SELECT
            MONTHNAME(t.created_date) AS month,
            COUNT(DISTINCT t.id) AS total,
            'GeneXpert Reason Male PLHIV' AS indicator,
            GROUP_CONCAT(DISTINCT t.id) AS associated_ids
          FROM
              tests t
                  INNER JOIN orders o ON o.id = t.order_id
                  INNER JOIN encounters e ON e.id = o.encounter_id
                  INNER JOIN clients c ON c.id = e.client_id
                  INNER JOIN people p ON p.id = c.person_id
                  INNER JOIN test_type_indicator_mappings ttim ON ttim.test_types_id = t.test_type_id
                  INNER JOIN test_indicators ti ON ti.id = ttim.test_indicators_id
                  INNER JOIN test_results tr ON tr.test_indicator_id = ti.id
                      AND tr.test_id = t.id
                      AND tr.voided = 0
          WHERE
              t.test_type_id IN #{GlobalService.fetch_ids(TestType, ['TB Tests'], ['NLIMS_TT_0010_MWI'])}
              AND ti.id IN #{GlobalService.fetch_ids(TestIndicator, ['Reason For Testing'], ['NLIMS_TI_0233_MWI'])}
              AND t.id IN (
                  SELECT DISTINCT t2.id FROM tests t2
                  INNER JOIN test_type_indicator_mappings ttim2 ON ttim2.test_types_id = t2.test_type_id
                  INNER JOIN test_indicators ti2 ON ti2.id = ttim2.test_indicators_id
                  INNER JOIN test_results tr2 ON tr2.test_indicator_id = ti2.id AND tr2.test_id = t2.id AND tr2.voided = 0
                  WHERE ti2.id IN #{GlobalService.fetch_ids(TestIndicator, ['Gene Xpert MTB'], ['NLIMS_TI_0202_MWI'])}
              )
              AND YEAR(t.created_date) = #{year}
              AND t.status_id IN (4, 5)
              AND t.voided = 0
              AND p.sex = 'M'
              AND tr.value LIKE '%PLHIV%'
          GROUP BY MONTHNAME(t.created_date)
        SQL
      end

      # GeneXpert Reason Male Other Risk Groups
      def genexpert_reason_male_other
        ActiveRecord::Base.connection.execute('SET SESSION group_concat_max_len = 1000000')
        Report.find_by_sql <<~SQL
          SELECT
            MONTHNAME(t.created_date) AS month,
            COUNT(DISTINCT t.id) AS total,
            'GeneXpert Reason Male Other Risk Groups' AS indicator,
            GROUP_CONCAT(DISTINCT t.id) AS associated_ids
          FROM
              tests t
                  INNER JOIN orders o ON o.id = t.order_id
                  INNER JOIN encounters e ON e.id = o.encounter_id
                  INNER JOIN clients c ON c.id = e.client_id
                  INNER JOIN people p ON p.id = c.person_id
                  INNER JOIN test_type_indicator_mappings ttim ON ttim.test_types_id = t.test_type_id
                  INNER JOIN test_indicators ti ON ti.id = ttim.test_indicators_id
                  INNER JOIN test_results tr ON tr.test_indicator_id = ti.id
                      AND tr.test_id = t.id
                      AND tr.voided = 0
          WHERE
              t.test_type_id IN #{GlobalService.fetch_ids(TestType, ['TB Tests'], ['NLIMS_TT_0010_MWI'])}
              AND ti.id IN #{GlobalService.fetch_ids(TestIndicator, ['Reason For Testing'], ['NLIMS_TI_0233_MWI'])}
              AND t.id IN (
                  SELECT DISTINCT t2.id FROM tests t2
                  INNER JOIN test_type_indicator_mappings ttim2 ON ttim2.test_types_id = t2.test_type_id
                  INNER JOIN test_indicators ti2 ON ti2.id = ttim2.test_indicators_id
                  INNER JOIN test_results tr2 ON tr2.test_indicator_id = ti2.id AND tr2.test_id = t2.id AND tr2.voided = 0
                  WHERE ti2.id IN #{GlobalService.fetch_ids(TestIndicator, ['Gene Xpert MTB'], ['NLIMS_TI_0202_MWI'])}
              )
              AND YEAR(t.created_date) = #{year}
              AND t.status_id IN (4, 5)
              AND t.voided = 0
              AND p.sex = 'M'
              AND tr.value NOT LIKE '%Hospitalized%'
              AND tr.value NOT LIKE '%Presumptive MDR%'
              AND tr.value NOT LIKE '%PLHIV%'
          GROUP BY MONTHNAME(t.created_date)
        SQL
      end

      # GeneXpert Reason Female Hospitalized
      def genexpert_reason_female_hospitalized
        ActiveRecord::Base.connection.execute('SET SESSION group_concat_max_len = 1000000')
        Report.find_by_sql <<~SQL
          SELECT
            MONTHNAME(t.created_date) AS month,
            COUNT(DISTINCT t.id) AS total,
            'GeneXpert Reason Female Hospitalized' AS indicator,
            GROUP_CONCAT(DISTINCT t.id) AS associated_ids
          FROM
              tests t
                  INNER JOIN orders o ON o.id = t.order_id
                  INNER JOIN encounters e ON e.id = o.encounter_id
                  INNER JOIN clients c ON c.id = e.client_id
                  INNER JOIN people p ON p.id = c.person_id
                  INNER JOIN test_type_indicator_mappings ttim ON ttim.test_types_id = t.test_type_id
                  INNER JOIN test_indicators ti ON ti.id = ttim.test_indicators_id
                  INNER JOIN test_results tr ON tr.test_indicator_id = ti.id
                      AND tr.test_id = t.id
                      AND tr.voided = 0
          WHERE
              t.test_type_id IN #{GlobalService.fetch_ids(TestType, ['TB Tests'], ['NLIMS_TT_0010_MWI'])}
              AND ti.id IN #{GlobalService.fetch_ids(TestIndicator, ['Reason For Testing'], ['NLIMS_TI_0233_MWI'])}
              AND t.id IN (
                  SELECT DISTINCT t2.id FROM tests t2
                  INNER JOIN test_type_indicator_mappings ttim2 ON ttim2.test_types_id = t2.test_type_id
                  INNER JOIN test_indicators ti2 ON ti2.id = ttim2.test_indicators_id
                  INNER JOIN test_results tr2 ON tr2.test_indicator_id = ti2.id AND tr2.test_id = t2.id AND tr2.voided = 0
                  WHERE ti2.id IN #{GlobalService.fetch_ids(TestIndicator, ['Gene Xpert MTB'], ['NLIMS_TI_0202_MWI'])}
              )
              AND YEAR(t.created_date) = #{year}
              AND t.status_id IN (4, 5)
              AND t.voided = 0
              AND p.sex = 'F'
              AND tr.value LIKE '%Hospitalized%'
          GROUP BY MONTHNAME(t.created_date)
        SQL
      end

      # GeneXpert Reason Female Presumptive MDR
      def genexpert_reason_female_presumptive_mdr
        ActiveRecord::Base.connection.execute('SET SESSION group_concat_max_len = 1000000')
        Report.find_by_sql <<~SQL
          SELECT
            MONTHNAME(t.created_date) AS month,
            COUNT(DISTINCT t.id) AS total,
            'GeneXpert Reason Female Presumptive MDR' AS indicator,
            GROUP_CONCAT(DISTINCT t.id) AS associated_ids
          FROM
              tests t
                  INNER JOIN orders o ON o.id = t.order_id
                  INNER JOIN encounters e ON e.id = o.encounter_id
                  INNER JOIN clients c ON c.id = e.client_id
                  INNER JOIN people p ON p.id = c.person_id
                  INNER JOIN test_type_indicator_mappings ttim ON ttim.test_types_id = t.test_type_id
                  INNER JOIN test_indicators ti ON ti.id = ttim.test_indicators_id
                  INNER JOIN test_results tr ON tr.test_indicator_id = ti.id
                      AND tr.test_id = t.id
                      AND tr.voided = 0
          WHERE
              t.test_type_id IN #{GlobalService.fetch_ids(TestType, ['TB Tests'], ['NLIMS_TT_0010_MWI'])}
              AND ti.id IN #{GlobalService.fetch_ids(TestIndicator, ['Reason For Testing'], ['NLIMS_TI_0233_MWI'])}
              AND t.id IN (
                  SELECT DISTINCT t2.id FROM tests t2
                  INNER JOIN test_type_indicator_mappings ttim2 ON ttim2.test_types_id = t2.test_type_id
                  INNER JOIN test_indicators ti2 ON ti2.id = ttim2.test_indicators_id
                  INNER JOIN test_results tr2 ON tr2.test_indicator_id = ti2.id AND tr2.test_id = t2.id AND tr2.voided = 0
                  WHERE ti2.id IN #{GlobalService.fetch_ids(TestIndicator, ['Gene Xpert MTB'], ['NLIMS_TI_0202_MWI'])}
              )
              AND YEAR(t.created_date) = #{year}
              AND t.status_id IN (4, 5)
              AND t.voided = 0
              AND p.sex = 'F'
              AND tr.value LIKE '%Presumptive MDR%'
          GROUP BY MONTHNAME(t.created_date)
        SQL
      end

      # GeneXpert Reason Female PLHIV
      def genexpert_reason_female_plhiv
        ActiveRecord::Base.connection.execute('SET SESSION group_concat_max_len = 1000000')
        Report.find_by_sql <<~SQL
          SELECT
            MONTHNAME(t.created_date) AS month,
            COUNT(DISTINCT t.id) AS total,
            'GeneXpert Reason Female PLHIV' AS indicator,
            GROUP_CONCAT(DISTINCT t.id) AS associated_ids
          FROM
              tests t
                  INNER JOIN orders o ON o.id = t.order_id
                  INNER JOIN encounters e ON e.id = o.encounter_id
                  INNER JOIN clients c ON c.id = e.client_id
                  INNER JOIN people p ON p.id = c.person_id
                  INNER JOIN test_type_indicator_mappings ttim ON ttim.test_types_id = t.test_type_id
                  INNER JOIN test_indicators ti ON ti.id = ttim.test_indicators_id
                  INNER JOIN test_results tr ON tr.test_indicator_id = ti.id
                      AND tr.test_id = t.id
                      AND tr.voided = 0
          WHERE
              t.test_type_id IN #{GlobalService.fetch_ids(TestType, ['TB Tests'], ['NLIMS_TT_0010_MWI'])}
              AND ti.id IN #{GlobalService.fetch_ids(TestIndicator, ['Reason For Testing'], ['NLIMS_TI_0233_MWI'])}
              AND t.id IN (
                  SELECT DISTINCT t2.id FROM tests t2
                  INNER JOIN test_type_indicator_mappings ttim2 ON ttim2.test_types_id = t2.test_type_id
                  INNER JOIN test_indicators ti2 ON ti2.id = ttim2.test_indicators_id
                  INNER JOIN test_results tr2 ON tr2.test_indicator_id = ti2.id AND tr2.test_id = t2.id AND tr2.voided = 0
                  WHERE ti2.id IN #{GlobalService.fetch_ids(TestIndicator, ['Gene Xpert MTB'], ['NLIMS_TI_0202_MWI'])}
              )
              AND YEAR(t.created_date) = #{year}
              AND t.status_id IN (4, 5)
              AND t.voided = 0
              AND p.sex = 'F'
              AND tr.value LIKE '%PLHIV%'
          GROUP BY MONTHNAME(t.created_date)
        SQL
      end

      # GeneXpert Reason Female Other Risk Groups
      def genexpert_reason_female_other
        ActiveRecord::Base.connection.execute('SET SESSION group_concat_max_len = 1000000')
        Report.find_by_sql <<~SQL
          SELECT
            MONTHNAME(t.created_date) AS month,
            COUNT(DISTINCT t.id) AS total,
            'GeneXpert Reason Female Other Risk Groups' AS indicator,
            GROUP_CONCAT(DISTINCT t.id) AS associated_ids
          FROM
              tests t
                  INNER JOIN orders o ON o.id = t.order_id
                  INNER JOIN encounters e ON e.id = o.encounter_id
                  INNER JOIN clients c ON c.id = e.client_id
                  INNER JOIN people p ON p.id = c.person_id
                  INNER JOIN test_type_indicator_mappings ttim ON ttim.test_types_id = t.test_type_id
                  INNER JOIN test_indicators ti ON ti.id = ttim.test_indicators_id
                  INNER JOIN test_results tr ON tr.test_indicator_id = ti.id
                      AND tr.test_id = t.id
                      AND tr.voided = 0
          WHERE
              t.test_type_id IN #{GlobalService.fetch_ids(TestType, ['TB Tests'], ['NLIMS_TT_0010_MWI'])}
              AND ti.id IN #{GlobalService.fetch_ids(TestIndicator, ['Reason For Testing'], ['NLIMS_TI_0233_MWI'])}
              AND t.id IN (
                  SELECT DISTINCT t2.id FROM tests t2
                  INNER JOIN test_type_indicator_mappings ttim2 ON ttim2.test_types_id = t2.test_type_id
                  INNER JOIN test_indicators ti2 ON ti2.id = ttim2.test_indicators_id
                  INNER JOIN test_results tr2 ON tr2.test_indicator_id = ti2.id AND tr2.test_id = t2.id AND tr2.voided = 0
                  WHERE ti2.id IN #{GlobalService.fetch_ids(TestIndicator, ['Gene Xpert MTB'], ['NLIMS_TI_0202_MWI'])}
              )
              AND YEAR(t.created_date) = #{year}
              AND t.status_id IN (4, 5)
              AND t.voided = 0
              AND p.sex = 'F'
              AND tr.value NOT LIKE '%Hospitalized%'
              AND tr.value NOT LIKE '%Presumptive MDR%'
              AND tr.value NOT LIKE '%PLHIV%'
          GROUP BY MONTHNAME(t.created_date)
        SQL
      end

      # GeneXpert Reason Children Hospitalized
      def genexpert_reason_children_hospitalized
        ActiveRecord::Base.connection.execute('SET SESSION group_concat_max_len = 1000000')
        Report.find_by_sql <<~SQL
          SELECT
            MONTHNAME(t.created_date) AS month,
            COUNT(DISTINCT t.id) AS total,
            'GeneXpert Reason Children Hospitalized' AS indicator,
            GROUP_CONCAT(DISTINCT t.id) AS associated_ids
          FROM
              tests t
                  INNER JOIN orders o ON o.id = t.order_id
                  INNER JOIN encounters e ON e.id = o.encounter_id
                  INNER JOIN clients c ON c.id = e.client_id
                  INNER JOIN people p ON p.id = c.person_id
                  INNER JOIN test_type_indicator_mappings ttim ON ttim.test_types_id = t.test_type_id
                  INNER JOIN test_indicators ti ON ti.id = ttim.test_indicators_id
                  INNER JOIN test_results tr ON tr.test_indicator_id = ti.id
                      AND tr.test_id = t.id
                      AND tr.voided = 0
          WHERE
              t.test_type_id IN #{GlobalService.fetch_ids(TestType, ['TB Tests'], ['NLIMS_TT_0010_MWI'])}
              AND ti.id IN #{GlobalService.fetch_ids(TestIndicator, ['Reason For Testing'], ['NLIMS_TI_0233_MWI'])}
              AND t.id IN (
                  SELECT DISTINCT t2.id FROM tests t2
                  INNER JOIN test_type_indicator_mappings ttim2 ON ttim2.test_types_id = t2.test_type_id
                  INNER JOIN test_indicators ti2 ON ti2.id = ttim2.test_indicators_id
                  INNER JOIN test_results tr2 ON tr2.test_indicator_id = ti2.id AND tr2.test_id = t2.id AND tr2.voided = 0
                  WHERE ti2.id IN #{GlobalService.fetch_ids(TestIndicator, ['Gene Xpert MTB'], ['NLIMS_TI_0202_MWI'])}
              )
              AND YEAR(t.created_date) = #{year}
              AND t.status_id IN (4, 5)
              AND t.voided = 0
              AND TIMESTAMPDIFF(YEAR, p.date_of_birth, t.created_date) <= 12
              AND tr.value LIKE '%Hospitalized%'
          GROUP BY MONTHNAME(t.created_date)
        SQL
      end

      # GeneXpert Reason Children Presumptive MDR
      def genexpert_reason_children_presumptive_mdr
        ActiveRecord::Base.connection.execute('SET SESSION group_concat_max_len = 1000000')
        Report.find_by_sql <<~SQL
          SELECT
            MONTHNAME(t.created_date) AS month,
            COUNT(DISTINCT t.id) AS total,
            'GeneXpert Reason Children Presumptive MDR' AS indicator,
            GROUP_CONCAT(DISTINCT t.id) AS associated_ids
          FROM
              tests t
                  INNER JOIN orders o ON o.id = t.order_id
                  INNER JOIN encounters e ON e.id = o.encounter_id
                  INNER JOIN clients c ON c.id = e.client_id
                  INNER JOIN people p ON p.id = c.person_id
                  INNER JOIN test_type_indicator_mappings ttim ON ttim.test_types_id = t.test_type_id
                  INNER JOIN test_indicators ti ON ti.id = ttim.test_indicators_id
                  INNER JOIN test_results tr ON tr.test_indicator_id = ti.id
                      AND tr.test_id = t.id
                      AND tr.voided = 0
          WHERE
              t.test_type_id IN #{GlobalService.fetch_ids(TestType, ['TB Tests'], ['NLIMS_TT_0010_MWI'])}
              AND ti.id IN #{GlobalService.fetch_ids(TestIndicator, ['Reason For Testing'], ['NLIMS_TI_0233_MWI'])}
              AND t.id IN (
                  SELECT DISTINCT t2.id FROM tests t2
                  INNER JOIN test_type_indicator_mappings ttim2 ON ttim2.test_types_id = t2.test_type_id
                  INNER JOIN test_indicators ti2 ON ti2.id = ttim2.test_indicators_id
                  INNER JOIN test_results tr2 ON tr2.test_indicator_id = ti2.id AND tr2.test_id = t2.id AND tr2.voided = 0
                  WHERE ti2.id IN #{GlobalService.fetch_ids(TestIndicator, ['Gene Xpert MTB'], ['NLIMS_TI_0202_MWI'])}
              )
              AND YEAR(t.created_date) = #{year}
              AND t.status_id IN (4, 5)
              AND t.voided = 0
              AND TIMESTAMPDIFF(YEAR, p.date_of_birth, t.created_date) <= 12
              AND tr.value LIKE '%Presumptive MDR%'
          GROUP BY MONTHNAME(t.created_date)
        SQL
      end

      # GeneXpert Reason Children PLHIV
      def genexpert_reason_children_plhiv
        ActiveRecord::Base.connection.execute('SET SESSION group_concat_max_len = 1000000')
        Report.find_by_sql <<~SQL
          SELECT
            MONTHNAME(t.created_date) AS month,
            COUNT(DISTINCT t.id) AS total,
            'GeneXpert Reason Children PLHIV' AS indicator,
            GROUP_CONCAT(DISTINCT t.id) AS associated_ids
          FROM
              tests t
                  INNER JOIN orders o ON o.id = t.order_id
                  INNER JOIN encounters e ON e.id = o.encounter_id
                  INNER JOIN clients c ON c.id = e.client_id
                  INNER JOIN people p ON p.id = c.person_id
                  INNER JOIN test_type_indicator_mappings ttim ON ttim.test_types_id = t.test_type_id
                  INNER JOIN test_indicators ti ON ti.id = ttim.test_indicators_id
                  INNER JOIN test_results tr ON tr.test_indicator_id = ti.id
                      AND tr.test_id = t.id
                      AND tr.voided = 0
          WHERE
              t.test_type_id IN #{GlobalService.fetch_ids(TestType, ['TB Tests'], ['NLIMS_TT_0010_MWI'])}
              AND ti.id IN #{GlobalService.fetch_ids(TestIndicator, ['Reason For Testing'], ['NLIMS_TI_0233_MWI'])}
              AND t.id IN (
                  SELECT DISTINCT t2.id FROM tests t2
                  INNER JOIN test_type_indicator_mappings ttim2 ON ttim2.test_types_id = t2.test_type_id
                  INNER JOIN test_indicators ti2 ON ti2.id = ttim2.test_indicators_id
                  INNER JOIN test_results tr2 ON tr2.test_indicator_id = ti2.id AND tr2.test_id = t2.id AND tr2.voided = 0
                  WHERE ti2.id IN #{GlobalService.fetch_ids(TestIndicator, ['Gene Xpert MTB'], ['NLIMS_TI_0202_MWI'])}
              )
              AND YEAR(t.created_date) = #{year}
              AND t.status_id IN (4, 5)
              AND t.voided = 0
              AND TIMESTAMPDIFF(YEAR, p.date_of_birth, t.created_date) <= 12
              AND tr.value LIKE '%PLHIV%'
          GROUP BY MONTHNAME(t.created_date)
        SQL
      end

      # GeneXpert Reason Children Other Risk Groups
      def genexpert_reason_children_other
        ActiveRecord::Base.connection.execute('SET SESSION group_concat_max_len = 1000000')
        Report.find_by_sql <<~SQL
          SELECT
            MONTHNAME(t.created_date) AS month,
            COUNT(DISTINCT t.id) AS total,
            'GeneXpert Reason Children Other Risk Groups' AS indicator,
            GROUP_CONCAT(DISTINCT t.id) AS associated_ids
          FROM
              tests t
                  INNER JOIN orders o ON o.id = t.order_id
                  INNER JOIN encounters e ON e.id = o.encounter_id
                  INNER JOIN clients c ON c.id = e.client_id
                  INNER JOIN people p ON p.id = c.person_id
                  INNER JOIN test_type_indicator_mappings ttim ON ttim.test_types_id = t.test_type_id
                  INNER JOIN test_indicators ti ON ti.id = ttim.test_indicators_id
                  INNER JOIN test_results tr ON tr.test_indicator_id = ti.id
                      AND tr.test_id = t.id
                      AND tr.voided = 0
          WHERE
              t.test_type_id IN #{GlobalService.fetch_ids(TestType, ['TB Tests'], ['NLIMS_TT_0010_MWI'])}
              AND ti.id IN #{GlobalService.fetch_ids(TestIndicator, ['Reason For Testing'], ['NLIMS_TI_0233_MWI'])}
              AND t.id IN (
                  SELECT DISTINCT t2.id FROM tests t2
                  INNER JOIN test_type_indicator_mappings ttim2 ON ttim2.test_types_id = t2.test_type_id
                  INNER JOIN test_indicators ti2 ON ti2.id = ttim2.test_indicators_id
                  INNER JOIN test_results tr2 ON tr2.test_indicator_id = ti2.id AND tr2.test_id = t2.id AND tr2.voided = 0
                  WHERE ti2.id IN #{GlobalService.fetch_ids(TestIndicator, ['Gene Xpert MTB'], ['NLIMS_TI_0202_MWI'])}
              )
              AND YEAR(t.created_date) = #{year}
              AND t.status_id IN (4, 5)
              AND t.voided = 0
              AND TIMESTAMPDIFF(YEAR, p.date_of_birth, t.created_date) <= 12
              AND tr.value NOT LIKE '%Hospitalized%'
              AND tr.value NOT LIKE '%Presumptive MDR%'
              AND tr.value NOT LIKE '%PLHIV%'
          GROUP BY MONTHNAME(t.created_date)
        SQL
      end

      # GeneXpert Total cartridges used (same as total tests done)
      def genexpert_total_cartridges
        ActiveRecord::Base.connection.execute('SET SESSION group_concat_max_len = 1000000')
        Report.find_by_sql <<~SQL
          SELECT
            MONTHNAME(t.created_date) AS month,
            COUNT(DISTINCT t.id) AS total,
            'GeneXpert Total cartridges used' AS indicator,
            GROUP_CONCAT(DISTINCT t.id) AS associated_ids
          FROM
              tests t
                  INNER JOIN test_type_indicator_mappings ttim ON ttim.test_types_id = t.test_type_id
                  INNER JOIN test_indicators ti ON ti.id = ttim.test_indicators_id
                  INNER JOIN test_results tr ON tr.test_indicator_id = ti.id
                      AND tr.test_id = t.id
                      AND tr.voided = 0
          WHERE
              t.test_type_id IN #{GlobalService.fetch_ids(TestType, ['TB Tests'], ['NLIMS_TT_0010_MWI'])}
              AND ti.id IN #{GlobalService.fetch_ids(TestIndicator, ['Gene Xpert MTB'], ['NLIMS_TI_0202_MWI'])}
              AND YEAR(t.created_date) = #{year}
              AND t.status_id IN (4, 5)
              AND t.voided = 0
          GROUP BY MONTHNAME(t.created_date)
        SQL
      end

      # GeneXpert MTB not detected - Male
      def genexpert_mtb_not_detected_male
        ActiveRecord::Base.connection.execute('SET SESSION group_concat_max_len = 1000000')
        Report.find_by_sql <<~SQL
          SELECT
            MONTHNAME(t.created_date) AS month,
            COUNT(DISTINCT t.id) AS total,
            'GeneXpert MTB not detected Male' AS indicator,
            GROUP_CONCAT(DISTINCT t.id) AS associated_ids
          FROM
              tests t
                  INNER JOIN orders o ON o.id = t.order_id
                  INNER JOIN encounters e ON e.id = o.encounter_id
                  INNER JOIN clients c ON c.id = e.client_id
                  INNER JOIN people p ON p.id = c.person_id
                  INNER JOIN test_type_indicator_mappings ttim ON ttim.test_types_id = t.test_type_id
                  INNER JOIN test_indicators ti ON ti.id = ttim.test_indicators_id
                  INNER JOIN test_results tr ON tr.test_indicator_id = ti.id
                      AND tr.test_id = t.id
                      AND tr.voided = 0
          WHERE
              t.test_type_id IN #{GlobalService.fetch_ids(TestType, ['TB Tests'], ['NLIMS_TT_0010_MWI'])}
              AND ti.id IN #{GlobalService.fetch_ids(TestIndicator, ['Gene Xpert MTB'], ['NLIMS_TI_0202_MWI'])}
              AND YEAR(t.created_date) = #{year}
              AND t.status_id IN (4, 5)
              AND t.voided = 0
              AND p.sex = 'M'
              AND (tr.value LIKE '%Not Detected%' OR tr.value LIKE '%Negative%')
          GROUP BY MONTHNAME(t.created_date)
        SQL
      end

      # GeneXpert MTB not detected - Female
      def genexpert_mtb_not_detected_female
        ActiveRecord::Base.connection.execute('SET SESSION group_concat_max_len = 1000000')
        Report.find_by_sql <<~SQL
          SELECT
            MONTHNAME(t.created_date) AS month,
            COUNT(DISTINCT t.id) AS total,
            'GeneXpert MTB not detected Female' AS indicator,
            GROUP_CONCAT(DISTINCT t.id) AS associated_ids
          FROM
              tests t
                  INNER JOIN orders o ON o.id = t.order_id
                  INNER JOIN encounters e ON e.id = o.encounter_id
                  INNER JOIN clients c ON c.id = e.client_id
                  INNER JOIN people p ON p.id = c.person_id
                  INNER JOIN test_type_indicator_mappings ttim ON ttim.test_types_id = t.test_type_id
                  INNER JOIN test_indicators ti ON ti.id = ttim.test_indicators_id
                  INNER JOIN test_results tr ON tr.test_indicator_id = ti.id
                      AND tr.test_id = t.id
                      AND tr.voided = 0
          WHERE
              t.test_type_id IN #{GlobalService.fetch_ids(TestType, ['TB Tests'], ['NLIMS_TT_0010_MWI'])}
              AND ti.id IN #{GlobalService.fetch_ids(TestIndicator, ['Gene Xpert MTB'], ['NLIMS_TI_0202_MWI'])}
              AND YEAR(t.created_date) = #{year}
              AND t.status_id IN (4, 5)
              AND t.voided = 0
              AND p.sex = 'F'
              AND (tr.value LIKE '%Not Detected%' OR tr.value LIKE '%Negative%')
          GROUP BY MONTHNAME(t.created_date)
        SQL
      end

      # GeneXpert MTB not detected - Children
      def genexpert_mtb_not_detected_children
        ActiveRecord::Base.connection.execute('SET SESSION group_concat_max_len = 1000000')
        Report.find_by_sql <<~SQL
          SELECT
            MONTHNAME(t.created_date) AS month,
            COUNT(DISTINCT t.id) AS total,
            'GeneXpert MTB not detected Children' AS indicator,
            GROUP_CONCAT(DISTINCT t.id) AS associated_ids
          FROM
              tests t
                  INNER JOIN orders o ON o.id = t.order_id
                  INNER JOIN encounters e ON e.id = o.encounter_id
                  INNER JOIN clients c ON c.id = e.client_id
                  INNER JOIN people p ON p.id = c.person_id
                  INNER JOIN test_type_indicator_mappings ttim ON ttim.test_types_id = t.test_type_id
                  INNER JOIN test_indicators ti ON ti.id = ttim.test_indicators_id
                  INNER JOIN test_results tr ON tr.test_indicator_id = ti.id
                      AND tr.test_id = t.id
                      AND tr.voided = 0
          WHERE
              t.test_type_id IN #{GlobalService.fetch_ids(TestType, ['TB Tests'], ['NLIMS_TT_0010_MWI'])}
              AND ti.id IN #{GlobalService.fetch_ids(TestIndicator, ['Gene Xpert MTB'], ['NLIMS_TI_0202_MWI'])}
              AND YEAR(t.created_date) = #{year}
              AND t.status_id IN (4, 5)
              AND t.voided = 0
              AND TIMESTAMPDIFF(YEAR, p.date_of_birth, t.created_date) <= 12
              AND (tr.value LIKE '%Not Detected%' OR tr.value LIKE '%Negative%')
          GROUP BY MONTHNAME(t.created_date)
        SQL
      end

      # GeneXpert MTB detected - Male
      def genexpert_mtb_detected_male
        ActiveRecord::Base.connection.execute('SET SESSION group_concat_max_len = 1000000')
        Report.find_by_sql <<~SQL
          SELECT
            MONTHNAME(t.created_date) AS month,
            COUNT(DISTINCT t.id) AS total,
            'GeneXpert MTB detected Male' AS indicator,
            GROUP_CONCAT(DISTINCT t.id) AS associated_ids
          FROM
              tests t
                  INNER JOIN orders o ON o.id = t.order_id
                  INNER JOIN encounters e ON e.id = o.encounter_id
                  INNER JOIN clients c ON c.id = e.client_id
                  INNER JOIN people p ON p.id = c.person_id
                  INNER JOIN test_type_indicator_mappings ttim ON ttim.test_types_id = t.test_type_id
                  INNER JOIN test_indicators ti ON ti.id = ttim.test_indicators_id
                  INNER JOIN test_results tr ON tr.test_indicator_id = ti.id
                      AND tr.test_id = t.id
                      AND tr.voided = 0
          WHERE
              t.test_type_id IN #{GlobalService.fetch_ids(TestType, ['TB Tests'], ['NLIMS_TT_0010_MWI'])}
              AND ti.id IN #{GlobalService.fetch_ids(TestIndicator, ['Gene Xpert MTB'], ['NLIMS_TI_0202_MWI'])}
              AND YEAR(t.created_date) = #{year}
              AND t.status_id IN (4, 5)
              AND t.voided = 0
              AND p.sex = 'M'
              AND (tr.value LIKE '%Detected%' OR tr.value LIKE '%Positive%')
              AND tr.value NOT LIKE '%Not Detected%'
          GROUP BY MONTHNAME(t.created_date)
        SQL
      end

      # GeneXpert MTB detected - Female
      def genexpert_mtb_detected_female
        ActiveRecord::Base.connection.execute('SET SESSION group_concat_max_len = 1000000')
        Report.find_by_sql <<~SQL
          SELECT
            MONTHNAME(t.created_date) AS month,
            COUNT(DISTINCT t.id) AS total,
            'GeneXpert MTB detected Female' AS indicator,
            GROUP_CONCAT(DISTINCT t.id) AS associated_ids
          FROM
              tests t
                  INNER JOIN orders o ON o.id = t.order_id
                  INNER JOIN encounters e ON e.id = o.encounter_id
                  INNER JOIN clients c ON c.id = e.client_id
                  INNER JOIN people p ON p.id = c.person_id
                  INNER JOIN test_type_indicator_mappings ttim ON ttim.test_types_id = t.test_type_id
                  INNER JOIN test_indicators ti ON ti.id = ttim.test_indicators_id
                  INNER JOIN test_results tr ON tr.test_indicator_id = ti.id
                      AND tr.test_id = t.id
                      AND tr.voided = 0
          WHERE
              t.test_type_id IN #{GlobalService.fetch_ids(TestType, ['TB Tests'], ['NLIMS_TT_0010_MWI'])}
              AND ti.id IN #{GlobalService.fetch_ids(TestIndicator, ['Gene Xpert MTB'], ['NLIMS_TI_0202_MWI'])}
              AND YEAR(t.created_date) = #{year}
              AND t.status_id IN (4, 5)
              AND t.voided = 0
              AND p.sex = 'F'
              AND (tr.value LIKE '%Detected%' OR tr.value LIKE '%Positive%')
              AND tr.value NOT LIKE '%Not Detected%'
          GROUP BY MONTHNAME(t.created_date)
        SQL
      end

      # GeneXpert MTB detected - Children
      def genexpert_mtb_detected_children
        ActiveRecord::Base.connection.execute('SET SESSION group_concat_max_len = 1000000')
        Report.find_by_sql <<~SQL
          SELECT
            MONTHNAME(t.created_date) AS month,
            COUNT(DISTINCT t.id) AS total,
            'GeneXpert MTB detected Children' AS indicator,
            GROUP_CONCAT(DISTINCT t.id) AS associated_ids
          FROM
              tests t
                  INNER JOIN orders o ON o.id = t.order_id
                  INNER JOIN encounters e ON e.id = o.encounter_id
                  INNER JOIN clients c ON c.id = e.client_id
                  INNER JOIN people p ON p.id = c.person_id
                  INNER JOIN test_type_indicator_mappings ttim ON ttim.test_types_id = t.test_type_id
                  INNER JOIN test_indicators ti ON ti.id = ttim.test_indicators_id
                  INNER JOIN test_results tr ON tr.test_indicator_id = ti.id
                      AND tr.test_id = t.id
                      AND tr.voided = 0
          WHERE
              t.test_type_id IN #{GlobalService.fetch_ids(TestType, ['TB Tests'], ['NLIMS_TT_0010_MWI'])}
              AND ti.id IN #{GlobalService.fetch_ids(TestIndicator, ['Gene Xpert MTB'], ['NLIMS_TI_0202_MWI'])}
              AND YEAR(t.created_date) = #{year}
              AND t.status_id IN (4, 5)
              AND t.voided = 0
              AND TIMESTAMPDIFF(YEAR, p.date_of_birth, t.created_date) <= 12
              AND (tr.value LIKE '%Detected%' OR tr.value LIKE '%Positive%')
              AND tr.value NOT LIKE '%Not Detected%'
          GROUP BY MONTHNAME(t.created_date)
        SQL
      end

      # GeneXpert RIF detected - Male
      def genexpert_rif_detected_male
        ActiveRecord::Base.connection.execute('SET SESSION group_concat_max_len = 1000000')
        Report.find_by_sql <<~SQL
          SELECT
            MONTHNAME(t.created_date) AS month,
            COUNT(DISTINCT t.id) AS total,
            'GeneXpert RIF detected Male' AS indicator,
            GROUP_CONCAT(DISTINCT t.id) AS associated_ids
          FROM
              tests t
                  INNER JOIN orders o ON o.id = t.order_id
                  INNER JOIN encounters e ON e.id = o.encounter_id
                  INNER JOIN clients c ON c.id = e.client_id
                  INNER JOIN people p ON p.id = c.person_id
                  INNER JOIN test_type_indicator_mappings ttim ON ttim.test_types_id = t.test_type_id
                  INNER JOIN test_indicators ti ON ti.id = ttim.test_indicators_id
                  INNER JOIN test_results tr ON tr.test_indicator_id = ti.id
                      AND tr.test_id = t.id
                      AND tr.voided = 0
          WHERE
              t.test_type_id IN #{GlobalService.fetch_ids(TestType, ['TB Tests'], ['NLIMS_TT_0010_MWI'])}
              AND ti.id IN #{GlobalService.fetch_ids(TestIndicator, ['Gene Xpert RIF Resistance'], ['NLIMS_TI_0203_MWI'])}
              AND YEAR(t.created_date) = #{year}
              AND t.status_id IN (4, 5)
              AND t.voided = 0
              AND p.sex = 'M'
              AND (tr.value LIKE '%Detected%' OR tr.value LIKE '%Resistance%')
              AND tr.value NOT LIKE '%Not Detected%'
          GROUP BY MONTHNAME(t.created_date)
        SQL
      end

      # GeneXpert RIF detected - Female
      def genexpert_rif_detected_female
        ActiveRecord::Base.connection.execute('SET SESSION group_concat_max_len = 1000000')
        Report.find_by_sql <<~SQL
          SELECT
            MONTHNAME(t.created_date) AS month,
            COUNT(DISTINCT t.id) AS total,
            'GeneXpert RIF detected Female' AS indicator,
            GROUP_CONCAT(DISTINCT t.id) AS associated_ids
          FROM
              tests t
                  INNER JOIN orders o ON o.id = t.order_id
                  INNER JOIN encounters e ON e.id = o.encounter_id
                  INNER JOIN clients c ON c.id = e.client_id
                  INNER JOIN people p ON p.id = c.person_id
                  INNER JOIN test_type_indicator_mappings ttim ON ttim.test_types_id = t.test_type_id
                  INNER JOIN test_indicators ti ON ti.id = ttim.test_indicators_id
                  INNER JOIN test_results tr ON tr.test_indicator_id = ti.id
                      AND tr.test_id = t.id
                      AND tr.voided = 0
          WHERE
              t.test_type_id IN #{GlobalService.fetch_ids(TestType, ['TB Tests'], ['NLIMS_TT_0010_MWI'])}
              AND ti.id IN #{GlobalService.fetch_ids(TestIndicator, ['Gene Xpert RIF Resistance'], ['NLIMS_TI_0203_MWI'])}
              AND YEAR(t.created_date) = #{year}
              AND t.status_id IN (4, 5)
              AND t.voided = 0
              AND p.sex = 'F'
              AND (tr.value LIKE '%Detected%' OR tr.value LIKE '%Resistance%')
              AND tr.value NOT LIKE '%Not Detected%'
          GROUP BY MONTHNAME(t.created_date)
        SQL
      end

      # GeneXpert RIF detected - Children
      def genexpert_rif_detected_children
        ActiveRecord::Base.connection.execute('SET SESSION group_concat_max_len = 1000000')
        Report.find_by_sql <<~SQL
          SELECT
            MONTHNAME(t.created_date) AS month,
            COUNT(DISTINCT t.id) AS total,
            'GeneXpert RIF detected Children' AS indicator,
            GROUP_CONCAT(DISTINCT t.id) AS associated_ids
          FROM
              tests t
                  INNER JOIN orders o ON o.id = t.order_id
                  INNER JOIN encounters e ON e.id = o.encounter_id
                  INNER JOIN clients c ON c.id = e.client_id
                  INNER JOIN people p ON p.id = c.person_id
                  INNER JOIN test_type_indicator_mappings ttim ON ttim.test_types_id = t.test_type_id
                  INNER JOIN test_indicators ti ON ti.id = ttim.test_indicators_id
                  INNER JOIN test_results tr ON tr.test_indicator_id = ti.id
                      AND tr.test_id = t.id
                      AND tr.voided = 0
          WHERE
              t.test_type_id IN #{GlobalService.fetch_ids(TestType, ['TB Tests'], ['NLIMS_TT_0010_MWI'])}
              AND ti.id IN #{GlobalService.fetch_ids(TestIndicator, ['Gene Xpert RIF Resistance'], ['NLIMS_TI_0203_MWI'])}
              AND YEAR(t.created_date) = #{year}
              AND t.status_id IN (4, 5)
              AND t.voided = 0
              AND TIMESTAMPDIFF(YEAR, p.date_of_birth, t.created_date) <= 12
              AND (tr.value LIKE '%Detected%' OR tr.value LIKE '%Resistance%')
              AND tr.value NOT LIKE '%Not Detected%'
          GROUP BY MONTHNAME(t.created_date)
        SQL
      end

      # GeneXpert Indeterminate
      def genexpert_indeterminate
        ActiveRecord::Base.connection.execute('SET SESSION group_concat_max_len = 1000000')
        Report.find_by_sql <<~SQL
          SELECT
            MONTHNAME(t.created_date) AS month,
            COUNT(DISTINCT t.id) AS total,
            'GeneXpert Indeterminate' AS indicator,
            GROUP_CONCAT(DISTINCT t.id) AS associated_ids
          FROM
              tests t
                  INNER JOIN test_type_indicator_mappings ttim ON ttim.test_types_id = t.test_type_id
                  INNER JOIN test_indicators ti ON ti.id = ttim.test_indicators_id
                  INNER JOIN test_results tr ON tr.test_indicator_id = ti.id
                      AND tr.test_id = t.id
                      AND tr.voided = 0
          WHERE
              t.test_type_id IN #{GlobalService.fetch_ids(TestType, ['TB Tests'], ['NLIMS_TT_0010_MWI'])}
              AND ti.id IN #{GlobalService.fetch_ids(TestIndicator, ['Gene Xpert MTB'], ['NLIMS_TI_0202_MWI'])}
              AND YEAR(t.created_date) = #{year}
              AND t.status_id IN (4, 5)
              AND t.voided = 0
              AND tr.value LIKE '%Indeterminate%'
          GROUP BY MONTHNAME(t.created_date)
        SQL
      end

      # GeneXpert Total Errors
      def genexpert_total_errors
        ActiveRecord::Base.connection.execute('SET SESSION group_concat_max_len = 1000000')
        Report.find_by_sql <<~SQL
          SELECT
            MONTHNAME(t.created_date) AS month,
            COUNT(DISTINCT t.id) AS total,
            'GeneXpert Total Errors' AS indicator,
            GROUP_CONCAT(DISTINCT t.id) AS associated_ids
          FROM
              tests t
                  INNER JOIN test_type_indicator_mappings ttim ON ttim.test_types_id = t.test_type_id
                  INNER JOIN test_indicators ti ON ti.id = ttim.test_indicators_id
                  INNER JOIN test_results tr ON tr.test_indicator_id = ti.id
                      AND tr.test_id = t.id
                      AND tr.voided = 0
          WHERE
              t.test_type_id IN #{GlobalService.fetch_ids(TestType, ['TB Tests'], ['NLIMS_TT_0010_MWI'])}
              AND ti.id IN #{GlobalService.fetch_ids(TestIndicator, ['Gene Xpert MTB'], ['NLIMS_TI_0202_MWI'])}
              AND YEAR(t.created_date) = #{year}
              AND t.status_id IN (4, 5)
              AND t.voided = 0
              AND tr.value LIKE '%Error%'
          GROUP BY MONTHNAME(t.created_date)
        SQL
      end

      # GeneXpert No Results
      def genexpert_no_results
        ActiveRecord::Base.connection.execute('SET SESSION group_concat_max_len = 1000000')
        Report.find_by_sql <<~SQL
          SELECT
            MONTHNAME(t.created_date) AS month,
            COUNT(DISTINCT t.id) AS total,
            'GeneXpert No Results' AS indicator,
            GROUP_CONCAT(DISTINCT t.id) AS associated_ids
          FROM
              tests t
                  INNER JOIN test_type_indicator_mappings ttim ON ttim.test_types_id = t.test_type_id
                  INNER JOIN test_indicators ti ON ti.id = ttim.test_indicators_id
                  INNER JOIN test_results tr ON tr.test_indicator_id = ti.id
                      AND tr.test_id = t.id
                      AND tr.voided = 0
          WHERE
              t.test_type_id IN #{GlobalService.fetch_ids(TestType, ['TB Tests'], ['NLIMS_TT_0010_MWI'])}
              AND ti.id IN #{GlobalService.fetch_ids(TestIndicator, ['Gene Xpert MTB'], ['NLIMS_TI_0202_MWI'])}
              AND YEAR(t.created_date) = #{year}
              AND t.status_id IN (4, 5)
              AND t.voided = 0
              AND (tr.value LIKE '%No Result%' OR tr.value = '' OR tr.value IS NULL)
          GROUP BY MONTHNAME(t.created_date)
        SQL
      end
    end
  end
end
