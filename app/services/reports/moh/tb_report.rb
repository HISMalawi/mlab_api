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
                      total_follow_ups_6_7_months + total_negative_6_7_months + total_positive_6_7_months
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
        'Total Positive Microscopy 6/7 months'
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
    end
  end
end
