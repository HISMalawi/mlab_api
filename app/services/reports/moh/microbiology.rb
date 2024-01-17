# frozen_string_literal: true

# Module defines methods for Microbiology generating reports
module Reports
  # Generates Microbiology reports
  module Moh
    # Microbiology reports
    class Microbiology
      include Reports::Moh::MigrationHelpers::ExecuteQueries
      attr_reader :report, :report_indicator
      attr_accessor :year

      def initialize
        @report = {}
        @report_indicator = REPORT_INDICATORS
        initialize_report_counts
      end

      def generate_report
        report_data = number_of_afb_examined + new_tb_cases_examined + positive_new_tb_cases_examined + total_tb_lam +
                      rif_resistance_detected + mtb_not_detected + mtb_detected + rif_resistance_not_detected +
                      rif_resistance_indeterminate + no_results + invalid + covid_tests_performed +
                      covid_tests_positive_results + covid_tests_invalid_results + covid_tests_no_results +
                      covid_tests_error_results + positive_culture + culture
        data = update_report_counts(report_data)
        Report.find_or_create_by(name: 'moh_microbiology', year:).update(data:)
        data
      end

      private

      REPORT_INDICATORS = [
        'Number of AFB sputum examined',
        'Number of  new TB cases examined',
        'New cases with positive smear',
        'TB LAM Total',
        'TB LAM Positive',
        'MTB Not Detected',
        'MTB Detected',
        'RIF Resistant Detected',
        'RIF Resistant Not Detected',
        'RIF Resistant Indeterminate',
        'Invalid',
        'No results',
        'Total number of COVID-19 tests performed',
        'Total number of SARS-COV2 Positive',
        'Total number of INVALID SARS-COV2 results',
        'Total number of NO RESULTS',
        'Total number of ERROR results',
        'DNA-EID samples received',
        'DNA-EID tests done',
        'Number with positive results',
        'VL samples received',
        'VL tests done',
        'VL results with less than 1000 copies per ml',
        'Number of CSF samples analysed',
        'Number of CSF samples analysed for AFB',
        'Number of CSF samples with Organism',
        'Number of CSF cultures done',
        'Positive CSF cultures',
        'Total India ink done',
        'India ink positive',
        'Total Gram stain done',
        'Gram stain positive',
        'HVS analysed',
        'HVS with organism',
        'HVS Culture',
        'HVS Culture Positive',
        'Other swabs analysed',
        'Other swabs with organism',
        'Other swabs culture',
        'Other swabs culture Positive',
        'Number of Blood Cultures done',
        'Positive blood Cultures',
        'Cryptococcal antigen test',
        'Cryptococcal antigen test Positive',
        'Serum Crag',
        'Serum Crag Positive',
        'Total number of fluids analysed',
        'Fluids with organisms',
        'Cholera Rapid Diagnostic test done',
        'Positive Cholera Rapid Diagnostic test',
        'Cholera cultures done',
        'Positive cholera samples',
        'Other stool cultures',
        'Stool samples with organisms isolated on culture',
        'Urine culture',
        'Urine culture Positive'
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

      def number_of_afb_examined
        Report.find_by_sql <<~SQL
          SELECT
            MONTHNAME(t.created_date) AS month,
            COUNT(DISTINCT t.id) AS total, 'Number of AFB sputum examined' AS indicator
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
              t.test_type_id IN #{report_utils.test_type_ids('TB Tests')}
                  AND ti.id IN #{report_utils.test_indicator_ids('Smear Microscopy')}
                  AND YEAR(t.created_date) = #{year}
                  AND ts.status_id IN (4 , 5)
                  AND t.voided = 0
                  AND tr.value NOT IN ('', '0')
                  AND tr.value IS NOT NULL
          GROUP BY MONTHNAME(t.created_date)
        SQL
      end

      def new_tb_cases_examined
        Report.find_by_sql <<~SQL
          SELECT
            MONTHNAME(t.created_date) AS month,
            COUNT(DISTINCT t.id) AS total, 'Number of  new TB cases examined' AS indicator
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
              t.test_type_id IN #{report_utils.test_type_ids('TB Tests')}
                  AND YEAR(t.created_date) = #{year}
                  AND ts.status_id IN (4 , 5)
                  AND t.voided = 0
                  AND tr.value NOT IN ('', '0')
                  AND tr.value IS NOT NULL
          GROUP BY MONTHNAME(t.created_date)
        SQL
      end

      def positive_new_tb_cases_examined
        Report.find_by_sql <<~SQL
          SELECT
            MONTHNAME(t.created_date) AS month,
            COUNT(DISTINCT t.id) AS total,  'New cases with positive smear' AS indicator
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
              t.test_type_id IN #{report_utils.test_type_ids('TB Tests')}
                  AND ti.id IN #{report_utils.test_indicator_ids('Smear Microscopy')}
                  AND YEAR(t.created_date) = #{year}
                  AND ts.status_id IN (4 , 5)
                  AND t.voided = 0
                  AND tr.value NOT IN ('', '0')
                  AND tr.value IS NOT NULL
                  AND (tr.value LIKE '%+%' OR tr.value LIKE '%Scanty%' OR tr.value = 'Positive')
          GROUP BY MONTHNAME(t.created_date)
        SQL
      end

      def total_tb_lam
        Report.find_by_sql <<~SQL
          SELECT
            MONTHNAME(t.created_date) AS month,
            COUNT(DISTINCT t.id) AS total, 'TB LAM Total' AS indicator
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
              t.test_type_id IN #{report_utils.test_type_ids('TB LAM')}
                  AND YEAR(t.created_date) = #{year}
                  AND ts.status_id IN (4 , 5)
                  AND t.voided = 0
                  AND tr.value NOT IN ('', '0')
                  AND tr.value IS NOT NULL
          GROUP BY MONTHNAME(t.created_date)
        SQL
      end

      def mtb_not_detected
        Report.find_by_sql <<~SQL
            SELECT
              MONTHNAME(t.created_date) AS month,
              COUNT(DISTINCT t.id) AS total, 'MTB Not Detected' AS indicator
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
              t.test_type_id IN #{report_utils.test_type_ids('TB Tests')}
                  AND ti.id IN #{report_utils.test_indicator_ids('Gene Xpert MTB')}
                  AND YEAR(t.created_date) = #{year}
                  AND ts.status_id IN (4 , 5)
                  AND t.voided = 0
                  AND tr.value NOT IN ('', '0')
                  AND tr.value IS NOT NULL
                  AND tr.value LIKE '%NOT%'
          GROUP BY MONTHNAME(t.created_date)
        SQL
      end

      def mtb_detected
        Report.find_by_sql <<~SQL
          SELECT
            MONTHNAME(t.created_date) AS month,
            COUNT(DISTINCT t.id) AS total, 'MTB Detected' AS indicator
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
              t.test_type_id IN #{report_utils.test_type_ids('TB Tests')}
                  AND ti.id IN #{report_utils.test_indicator_ids('Gene Xpert MTB')}
                  AND YEAR(t.created_date) = #{year}
                  AND ts.status_id IN (4 , 5)
                  AND t.voided = 0
                  AND tr.value NOT IN ('', '0')
                  AND tr.value IS NOT NULL
                  AND (tr.value LIKE '%DETECTED%' AND tr.value NOT LIKE '%NOT%')
          GROUP BY MONTHNAME(t.created_date)
        SQL
      end

      def rif_resistance_detected
        Report.find_by_sql <<~SQL
          SELECT
            MONTHNAME(t.created_date) AS month,
            COUNT(DISTINCT t.id) AS total, 'RIF Resistant Detected' AS indicator
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
              t.test_type_id IN #{report_utils.test_type_ids('TB Tests')}
                  AND ti.id IN #{report_utils.test_indicator_ids('Gene Xpert RIF Resistance')}
                  AND YEAR(t.created_date) = #{year}
                  AND ts.status_id IN (4 , 5)
                  AND t.voided = 0
                  AND tr.value NOT IN ('', '0')
                  AND tr.value IS NOT NULL
                  AND (tr.value LIKE '%DETECTED%' AND tr.value NOT LIKE '%NOT%')
          GROUP BY MONTHNAME(t.created_date)
        SQL
      end

      def rif_resistance_indeterminate
        Report.find_by_sql <<~SQL
          SELECT
            MONTHNAME(t.created_date) AS month,
            COUNT(DISTINCT t.id) AS total, 'RIF Resistant Indeterminate' AS indicator
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
              t.test_type_id IN #{report_utils.test_type_ids('TB Tests')}
                  AND ti.id IN #{report_utils.test_indicator_ids('Gene Xpert RIF Resistance')}
                  AND YEAR(t.created_date) = #{year}
                  AND ts.status_id IN (4 , 5)
                  AND t.voided = 0
                  AND tr.value NOT IN ('', '0')
                  AND tr.value IS NOT NULL
                  AND tr.value LIKE '%Indetermi%'
          GROUP BY MONTHNAME(t.created_date)
        SQL
      end

      def rif_resistance_not_detected
        Report.find_by_sql <<~SQL
          SELECT
            MONTHNAME(t.created_date) AS month,
            COUNT(DISTINCT t.id) AS total, 'RIF Resistant Not Detected' AS indicator
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
              t.test_type_id IN #{report_utils.test_type_ids('TB Tests')}
                  AND ti.id IN #{report_utils.test_indicator_ids('Gene Xpert RIF Resistance')}
                  AND YEAR(t.created_date) = #{year}
                  AND ts.status_id IN (4 , 5)
                  AND t.voided = 0
                  AND tr.value NOT IN ('', '0')
                  AND tr.value IS NOT NULL
                  AND tr.value LIKE '%NOT%'
          GROUP BY MONTHNAME(t.created_date)
        SQL
      end

      def invalid
        Report.find_by_sql <<~SQL
          SELECT
            MONTHNAME(t.created_date) AS month,
            COUNT(DISTINCT t.id) AS total, 'Invalid' AS indicator
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
              t.test_type_id IN #{report_utils.test_type_ids('TB Tests')}
                  AND ti.id IN #{report_utils.test_indicator_ids('Gene Xpert MTB')}
                  AND YEAR(t.created_date) = #{year}
                  AND ts.status_id IN (4 , 5)
                  AND t.voided = 0
                  AND tr.value NOT IN ('', '0')
                  AND tr.value IS NOT NULL
                  AND tr.value LIKE '%Invalid%'
          GROUP BY MONTHNAME(t.created_date)
        SQL
      end

      def no_results
        Report.find_by_sql <<~SQL
          SELECT
            MONTHNAME(t.created_date) AS month,
            COUNT(DISTINCT t.id) AS total, 'No results' AS indicator
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
              t.test_type_id IN #{report_utils.test_type_ids('TB Tests')}
                  AND ti.id IN #{report_utils.test_indicator_ids('Gene Xpert MTB')}
                  AND YEAR(t.created_date) = #{year}
                  AND ts.status_id IN (4 , 5)
                  AND t.voided = 0
                  AND tr.value NOT IN ('', '0')
                  AND tr.value IS NOT NULL
                  AND tr.value LIKE '%No result%'
          GROUP BY MONTHNAME(t.created_date)
        SQL
      end

      def covid_tests_performed
        Report.find_by_sql <<~SQL
          SELECT
            MONTHNAME(t.created_date) AS month,
            COUNT(DISTINCT t.id) AS total, 'Total number of COVID-19 tests performed' AS indicator
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
              t.test_type_id IN #{report_utils.test_type_ids('COVID')}
                  AND YEAR(t.created_date) = #{year}
                  AND ts.status_id IN (4 , 5)
                  AND t.voided = 0
                  AND tr.value NOT IN ('', '0')
                  AND tr.value IS NOT NULL
          GROUP BY MONTHNAME(t.created_date)
        SQL
      end

      def covid_tests_positive_results
        Report.find_by_sql <<~SQL
          SELECT
            MONTHNAME(t.created_date) AS month,
            COUNT(DISTINCT t.id) AS total, 'Total number of SARS-COV2 Positive' AS indicator
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
              t.test_type_id IN #{report_utils.test_type_ids('COVID')}
                  AND YEAR(t.created_date) = #{year}
                  AND ts.status_id IN (4 , 5)
                  AND t.voided = 0
                  AND tr.value NOT IN ('', '0')
                  AND tr.value IS NOT NULL
                  AND tr.value = 'Positive'
          GROUP BY MONTHNAME(t.created_date)
        SQL
      end

      def covid_tests_invalid_results
        Report.find_by_sql <<~SQL
          SELECT
            MONTHNAME(t.created_date) AS month,
            COUNT(DISTINCT t.id) AS total, 'Total number of INVALID SARS-COV2 results' AS indicator
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
              t.test_type_id IN #{report_utils.test_type_ids('COVID')}
                  AND YEAR(t.created_date) = #{year}
                  AND ts.status_id IN (4 , 5)
                  AND t.voided = 0
                  AND tr.value NOT IN ('', '0')
                  AND tr.value IS NOT NULL
                  AND tr.value = 'Invalid'
          GROUP BY MONTHNAME(t.created_date)
        SQL
      end

      def covid_tests_no_results
        Report.find_by_sql <<~SQL
          SELECT
            MONTHNAME(t.created_date) AS month,
            COUNT(DISTINCT t.id) AS total, 'Total number of NO RESULTS' AS indicator
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
              t.test_type_id IN #{report_utils.test_type_ids('COVID')}
                  AND YEAR(t.created_date) = #{year}
                  AND ts.status_id IN (4 , 5)
                  AND t.voided = 0
                  AND tr.value NOT IN ('', '0')
                  AND tr.value IS NOT NULL
                  AND tr.value = 'NO RESULTS'
          GROUP BY MONTHNAME(t.created_date)
        SQL
      end

      def covid_tests_error_results
        Report.find_by_sql <<~SQL
          SELECT
            MONTHNAME(t.created_date) AS month,
            COUNT(DISTINCT t.id) AS total, 'Total number of ERROR results' AS indicator
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
              t.test_type_id IN #{report_utils.test_type_ids('COVID')}
                  AND YEAR(t.created_date) = #{year}
                  AND ts.status_id IN (4 , 5)
                  AND t.voided = 0
                  AND tr.value NOT IN ('', '0')
                  AND tr.value IS NOT NULL
                  AND tr.value = 'ERROR'
          GROUP BY MONTHNAME(t.created_date)
        SQL
      end

      def positive_culture
        Report.find_by_sql <<~SQL
          SELECT
            CASE
              WHEN t.specimen_id IN #{report_utils.specimen_ids('Urine')} THEN 'Urine culture Positive'
              WHEN t.specimen_id IN #{report_utils.specimen_ids('Stool')} THEN 'Stool samples with organisms isolated on culture'
              ELSE 'Unknown'
            END AS indicator,
            MONTHNAME(t.created_date) AS month,
            COUNT(DISTINCT t.id) AS total
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
              t.test_type_id IN #{report_utils.test_type_ids('CS')}
                  AND YEAR(t.created_date) = #{year}
                  AND ts.status_id IN (4 , 5)
                  AND t.voided = 0
                  AND tr.value NOT IN ('', '0')
                  AND tr.value IS NOT NULL
                  AND tr.value = 'Growth'
          GROUP BY MONTHNAME(t.created_date), indicator
        SQL
      end

      def culture
        Report.find_by_sql <<~SQL
          SELECT
            CASE
              WHEN t.specimen_id IN #{report_utils.specimen_ids('Urine')} THEN 'Urine culture'
              WHEN t.specimen_id IN #{report_utils.specimen_ids('Stool')} THEN 'Other stool cultures'
              ELSE 'Unknown'
            END AS indicator,
            MONTHNAME(t.created_date) AS month,
            COUNT(DISTINCT t.id) AS total
          FROM tests t
                  INNER JOIN
              test_statuses ts ON ts.test_id = t.id
                  INNER JOIN
              test_indicators ti ON ti.test_type_id = t.test_type_id
                  INNER JOIN
              test_results tr ON tr.test_indicator_id = ti.id
                  AND tr.test_id = t.id
                  AND tr.voided = 0
          WHERE
              t.test_type_id IN #{report_utils.test_type_ids('CS')}
                  AND YEAR(t.created_date) = #{year}
                  AND ts.status_id IN (4 , 5)
                  AND t.voided = 0
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
