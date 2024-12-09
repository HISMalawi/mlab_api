# frozen_string_literal: true

# Module defines methods for Microbiology generating reports
module Reports
  # Generates Microbiology reports
  module Moh
    # Microbiology reports
    class Microbiology
      attr_reader :report, :report_indicator
      attr_accessor :year

      def initialize
        @report = {}
        @report_indicator = REPORT_INDICATORS
        initialize_report_counts
      end

      def generate_report
        data = Report.where(year:, name: 'moh_microbiology').first&.data
        return data if data.present?

        report_data = number_of_afb_examined + new_tb_cases_examined + positive_new_tb_cases_examined + total_tb_lam +
                      rif_resistance_detected + mtb_not_detected + mtb_detected + rif_resistance_not_detected +
                      rif_resistance_indeterminate + no_results + invalid + covid_tests_performed +
                      covid_tests_positive_results + covid_tests_invalid_results + covid_tests_no_results +
                      covid_tests_error_results + dna_eid_samples_received + dna_eid_positive_results +
                      vl_samples_received + vl_tests_done + vl_results_less_100copies_permil + csf_samples_analysed +
                      csf_samples_analysed_afb + csf_samples_analysed_afb + india_ink_tests_done +
                      csf_samples_organism + india_link_positive + gram_stain_done + gram_stain_positive +
                      hvs_analysed + hvs_organism + cryptococcal_antigen_tests + positive_cryptococcal_antigen_tests +
                      serum_crag + positive_serum_crag + other_swabs_analysed + other_swabs_organism + fluids_analysed +
                      culture + positive_culture + swab_positive_culture + cholera_culture + cholera_culture_positive +
                      cholera_rapid_diagnostic_done + cholera_rapid_diagonostic_positive
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
            @report[month_name][indicator.to_sym] = {
              count: 0,
              associated_ids: ''
            }
          end
        end
      end

      def update_report_counts(counts)
        counts.each do |count|
          month_name = count.month.downcase
          REPORT_INDICATORS.each do |_indicator|
            @report[month_name][count.indicator.to_sym] = {
              count: count.total,
              associated_ids: UtilsService.insert_drilldown({ associated_ids: count.associated_ids }, 'Microbiology')
            }
          end
        end
        @report
      end

      def number_of_afb_examined
        ActiveRecord::Base.connection.execute('SET SESSION group_concat_max_len = 1000000')
        Report.find_by_sql <<~SQL
          SELECT
            MONTHNAME(t.created_date) AS month,
            COUNT(DISTINCT t.id) AS total, 'Number of AFB sputum examined' AS indicator,
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
              t.test_type_id IN #{report_utils.test_type_ids('TB Tests')}
                  AND ti.id IN #{report_utils.test_indicator_ids('Smear Microscopy')}
                  AND YEAR(t.created_date) = #{year}
                  AND t.status_id IN (4 , 5)
                  AND t.voided = 0
                  AND tr.value NOT IN ('', '0')
                  AND tr.value IS NOT NULL
          GROUP BY MONTHNAME(t.created_date)
        SQL
      end

      def new_tb_cases_examined
        ActiveRecord::Base.connection.execute('SET SESSION group_concat_max_len = 1000000')
        Report.find_by_sql <<~SQL
          SELECT
            MONTHNAME(t.created_date) AS month,
            COUNT(DISTINCT t.id) AS total, 'Number of  new TB cases examined' AS indicator,
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
              t.test_type_id IN #{report_utils.test_type_ids('TB Tests')}
                  AND YEAR(t.created_date) = #{year}
                  AND t.status_id IN (4 , 5)
                  AND t.voided = 0
                  AND tr.value NOT IN ('', '0')
                  AND tr.value IS NOT NULL
          GROUP BY MONTHNAME(t.created_date)
        SQL
      end

      def positive_new_tb_cases_examined
        ActiveRecord::Base.connection.execute('SET SESSION group_concat_max_len = 1000000')
        Report.find_by_sql <<~SQL
          SELECT
            MONTHNAME(t.created_date) AS month,
            COUNT(DISTINCT t.id) AS total,  'New cases with positive smear' AS indicator,
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
              t.test_type_id IN #{report_utils.test_type_ids('TB Tests')}
                  AND ti.id IN #{report_utils.test_indicator_ids('Smear Microscopy')}
                  AND YEAR(t.created_date) = #{year}
                  AND t.status_id IN (4 , 5)
                  AND t.voided = 0
                  AND tr.value NOT IN ('', '0')
                  AND tr.value IS NOT NULL
                  AND (tr.value LIKE '%+%' OR tr.value LIKE '%Scanty%' OR tr.value = 'Positive')
          GROUP BY MONTHNAME(t.created_date)
        SQL
      end

      def total_tb_lam
        ActiveRecord::Base.connection.execute('SET SESSION group_concat_max_len = 1000000')
        Report.find_by_sql <<~SQL
          SELECT
            MONTHNAME(t.created_date) AS month,
            COUNT(DISTINCT t.id) AS total, 'TB LAM Total' AS indicator,
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
              t.test_type_id IN #{report_utils.test_type_ids('TB LAM')}
                  AND YEAR(t.created_date) = #{year}
                  AND t.status_id IN (4 , 5)
                  AND t.voided = 0
                  AND tr.value NOT IN ('', '0')
                  AND tr.value IS NOT NULL
          GROUP BY MONTHNAME(t.created_date)
        SQL
      end

      def mtb_not_detected
        ActiveRecord::Base.connection.execute('SET SESSION group_concat_max_len = 1000000')
        Report.find_by_sql <<~SQL
            SELECT
              MONTHNAME(t.created_date) AS month,
              COUNT(DISTINCT t.id) AS total, 'MTB Not Detected' AS indicator,
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
              t.test_type_id IN #{report_utils.test_type_ids('TB Tests')}
                  AND ti.id IN #{report_utils.test_indicator_ids('Gene Xpert MTB')}
                  AND YEAR(t.created_date) = #{year}
                  AND t.status_id IN (4 , 5)
                  AND t.voided = 0
                  AND tr.value NOT IN ('', '0')
                  AND tr.value IS NOT NULL
                  AND tr.value LIKE '%NOT%'
          GROUP BY MONTHNAME(t.created_date)
        SQL
      end

      def mtb_detected
        ActiveRecord::Base.connection.execute('SET SESSION group_concat_max_len = 1000000')
        Report.find_by_sql <<~SQL
          SELECT
            MONTHNAME(t.created_date) AS month,
            COUNT(DISTINCT t.id) AS total, 'MTB Detected' AS indicator,
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
              t.test_type_id IN #{report_utils.test_type_ids('TB Tests')}
                  AND ti.id IN #{report_utils.test_indicator_ids('Gene Xpert MTB')}
                  AND YEAR(t.created_date) = #{year}
                  AND t.status_id IN (4 , 5)
                  AND t.voided = 0
                  AND tr.value NOT IN ('', '0')
                  AND tr.value IS NOT NULL
                  AND (tr.value LIKE '%DETECTED%' AND tr.value NOT LIKE '%NOT%')
          GROUP BY MONTHNAME(t.created_date)
        SQL
      end

      def rif_resistance_detected
        ActiveRecord::Base.connection.execute('SET SESSION group_concat_max_len = 1000000')
        Report.find_by_sql <<~SQL
          SELECT
            MONTHNAME(t.created_date) AS month,
            COUNT(DISTINCT t.id) AS total, 'RIF Resistant Detected' AS indicator,
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
              t.test_type_id IN #{report_utils.test_type_ids('TB Tests')}
                  AND ti.id IN #{report_utils.test_indicator_ids('Gene Xpert RIF Resistance')}
                  AND YEAR(t.created_date) = #{year}
                  AND t.status_id IN (4 , 5)
                  AND t.voided = 0
                  AND tr.value NOT IN ('', '0')
                  AND tr.value IS NOT NULL
                  AND (tr.value LIKE '%DETECTED%' AND tr.value NOT LIKE '%NOT%')
          GROUP BY MONTHNAME(t.created_date)
        SQL
      end

      def rif_resistance_indeterminate
        ActiveRecord::Base.connection.execute('SET SESSION group_concat_max_len = 1000000')
        Report.find_by_sql <<~SQL
          SELECT
            MONTHNAME(t.created_date) AS month,
            COUNT(DISTINCT t.id) AS total, 'RIF Resistant Indeterminate' AS indicator,
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
              t.test_type_id IN #{report_utils.test_type_ids('TB Tests')}
                  AND ti.id IN #{report_utils.test_indicator_ids('Gene Xpert RIF Resistance')}
                  AND YEAR(t.created_date) = #{year}
                  AND t.status_id IN (4 , 5)
                  AND t.voided = 0
                  AND tr.value NOT IN ('', '0')
                  AND tr.value IS NOT NULL
                  AND tr.value LIKE '%Indetermi%'
          GROUP BY MONTHNAME(t.created_date)
        SQL
      end

      def rif_resistance_not_detected
        ActiveRecord::Base.connection.execute('SET SESSION group_concat_max_len = 1000000')
        Report.find_by_sql <<~SQL
          SELECT
            MONTHNAME(t.created_date) AS month,
            COUNT(DISTINCT t.id) AS total, 'RIF Resistant Not Detected' AS indicator,
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
              t.test_type_id IN #{report_utils.test_type_ids('TB Tests')}
                  AND ti.id IN #{report_utils.test_indicator_ids('Gene Xpert RIF Resistance')}
                  AND YEAR(t.created_date) = #{year}
                  AND t.status_id IN (4 , 5)
                  AND t.voided = 0
                  AND tr.value NOT IN ('', '0')
                  AND tr.value IS NOT NULL
                  AND tr.value LIKE '%NOT%'
          GROUP BY MONTHNAME(t.created_date)
        SQL
      end

      def invalid
        ActiveRecord::Base.connection.execute('SET SESSION group_concat_max_len = 1000000')
        Report.find_by_sql <<~SQL
          SELECT
            MONTHNAME(t.created_date) AS month,
            COUNT(DISTINCT t.id) AS total, 'Invalid' AS indicator,
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
              t.test_type_id IN #{report_utils.test_type_ids('TB Tests')}
                  AND ti.id IN #{report_utils.test_indicator_ids('Gene Xpert MTB')}
                  AND YEAR(t.created_date) = #{year}
                  AND t.status_id IN (4 , 5)
                  AND t.voided = 0
                  AND tr.value NOT IN ('', '0')
                  AND tr.value IS NOT NULL
                  AND tr.value LIKE '%Invalid%'
          GROUP BY MONTHNAME(t.created_date)
        SQL
      end

      def no_results
        ActiveRecord::Base.connection.execute('SET SESSION group_concat_max_len = 1000000')
        Report.find_by_sql <<~SQL
          SELECT
            MONTHNAME(t.created_date) AS month,
            COUNT(DISTINCT t.id) AS total, 'No results' AS indicator,
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
              t.test_type_id IN #{report_utils.test_type_ids('TB Tests')}
                  AND ti.id IN #{report_utils.test_indicator_ids('Gene Xpert MTB')}
                  AND YEAR(t.created_date) = #{year}
                  AND t.status_id IN (4 , 5)
                  AND t.voided = 0
                  AND tr.value NOT IN ('', '0')
                  AND tr.value IS NOT NULL
                  AND tr.value LIKE '%No result%'
          GROUP BY MONTHNAME(t.created_date)
        SQL
      end

      def covid_tests_performed
        ActiveRecord::Base.connection.execute('SET SESSION group_concat_max_len = 1000000')
        Report.find_by_sql <<~SQL
          SELECT
            MONTHNAME(t.created_date) AS month,
            COUNT(DISTINCT t.id) AS total, 'Total number of COVID-19 tests performed' AS indicator,
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
              t.test_type_id IN #{report_utils.test_type_ids('COVID')}
                  AND YEAR(t.created_date) = #{year}
                  AND t.status_id IN (4 , 5)
                  AND t.voided = 0
                  AND tr.value NOT IN ('', '0')
                  AND tr.value IS NOT NULL
          GROUP BY MONTHNAME(t.created_date)
        SQL
      end

      def covid_tests_positive_results
        ActiveRecord::Base.connection.execute('SET SESSION group_concat_max_len = 1000000')
        Report.find_by_sql <<~SQL
          SELECT
            MONTHNAME(t.created_date) AS month,
            COUNT(DISTINCT t.id) AS total, 'Total number of SARS-COV2 Positive' AS indicator,
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
              t.test_type_id IN #{report_utils.test_type_ids('COVID')}
                  AND YEAR(t.created_date) = #{year}
                  AND t.status_id IN (4 , 5)
                  AND t.voided = 0
                  AND tr.value NOT IN ('', '0')
                  AND tr.value IS NOT NULL
                  AND tr.value = 'Positive'
          GROUP BY MONTHNAME(t.created_date)
        SQL
      end

      def covid_tests_invalid_results
        ActiveRecord::Base.connection.execute('SET SESSION group_concat_max_len = 1000000')
        Report.find_by_sql <<~SQL
          SELECT
            MONTHNAME(t.created_date) AS month,
            COUNT(DISTINCT t.id) AS total, 'Total number of INVALID SARS-COV2 results' AS indicator,
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
              t.test_type_id IN #{report_utils.test_type_ids('COVID')}
                  AND YEAR(t.created_date) = #{year}
                  AND t.status_id IN (4 , 5)
                  AND t.voided = 0
                  AND tr.value NOT IN ('', '0')
                  AND tr.value IS NOT NULL
                  AND tr.value = 'Invalid'
          GROUP BY MONTHNAME(t.created_date)
        SQL
      end

      def covid_tests_no_results
        ActiveRecord::Base.connection.execute('SET SESSION group_concat_max_len = 1000000')
        Report.find_by_sql <<~SQL
          SELECT
            MONTHNAME(t.created_date) AS month,
            COUNT(DISTINCT t.id) AS total, 'Total number of NO RESULTS' AS indicator,
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
              t.test_type_id IN #{report_utils.test_type_ids('COVID')}
                  AND YEAR(t.created_date) = #{year}
                  AND t.status_id IN (4 , 5)
                  AND t.voided = 0
                  AND tr.value NOT IN ('', '0')
                  AND tr.value IS NOT NULL
                  AND tr.value = 'NO RESULTS'
          GROUP BY MONTHNAME(t.created_date)
        SQL
      end

      def covid_tests_error_results
        ActiveRecord::Base.connection.execute('SET SESSION group_concat_max_len = 1000000')
        Report.find_by_sql <<~SQL
          SELECT
            MONTHNAME(t.created_date) AS month,
            COUNT(DISTINCT t.id) AS total, 'Total number of ERROR results' AS indicator,
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
              t.test_type_id IN #{report_utils.test_type_ids('COVID')}
                  AND YEAR(t.created_date) = #{year}
                  AND t.status_id IN (4 , 5)
                  AND t.voided = 0
                  AND tr.value NOT IN ('', '0')
                  AND tr.value IS NOT NULL
                  AND tr.value = 'ERROR'
          GROUP BY MONTHNAME(t.created_date)
        SQL
      end

      def positive_culture
        ActiveRecord::Base.connection.execute('SET SESSION group_concat_max_len = 1000000')
        Report.find_by_sql <<~SQL
          SELECT
            CASE
              WHEN t.specimen_id IN #{report_utils.specimen_ids('Urine')} THEN 'Urine culture Positive'
              WHEN t.specimen_id IN #{report_utils.specimen_ids('Stool')} THEN 'Stool samples with organisms isolated on culture'
              WHEN t.specimen_id IN #{report_utils.specimen_ids('Blood')} THEN 'Positive blood Cultures'
              WHEN t.specimen_id IN #{report_utils.specimen_ids_like('Fluid')} THEN 'Fluids with organisms'
              ELSE 'Unknown'
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
              t.test_type_id IN #{report_utils.test_type_ids('Cuture & Sensitivity')}
                  AND YEAR(t.created_date) = #{year}
                  AND t.status_id IN (4 , 5)
                  AND t.voided = 0
                  AND tr.value NOT IN ('', '0')
                  AND tr.value IS NOT NULL
                  AND tr.value = 'Growth'
          GROUP BY MONTHNAME(t.created_date), indicator
        SQL
      end

      def swab_positive_culture
        ActiveRecord::Base.connection.execute('SET SESSION group_concat_max_len = 1000000')
        Report.find_by_sql <<~SQL
          SELECT
            CASE
              WHEN t.specimen_id IN #{report_utils.specimen_ids('Swabs')} THEN 'Other swabs culture Positive'
              WHEN t.specimen_id IN #{report_utils.specimen_ids('HVS')} THEN 'HVS Culture Positive'
              WHEN t.specimen_id IN #{report_utils.specimen_ids('CSF')} THEN 'Positive CSF cultures'
              ELSE 'Unknown'
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
              t.test_type_id IN #{report_utils.test_type_ids('Cuture & Sensitivity')}
                  AND YEAR(t.created_date) = #{year}
                  AND t.status_id IN (4 , 5)
                  AND t.voided = 0
                  AND tr.value NOT IN ('', '0', 'No Growth', 'Growth of contaminants')
                  AND tr.value IS NOT NULL
                  AND tr.value NOT LIKE '%Growth of normal%'
          GROUP BY MONTHNAME(t.created_date), indicator
        SQL
      end

      def culture
        ActiveRecord::Base.connection.execute('SET SESSION group_concat_max_len = 1000000')
        Report.find_by_sql <<~SQL
          SELECT
            CASE
              WHEN t.specimen_id IN #{report_utils.specimen_ids('Urine')} THEN 'Urine culture'
              WHEN t.specimen_id IN #{report_utils.specimen_ids('Blood')} THEN 'Number of Blood Cultures done'
              WHEN t.specimen_id IN #{report_utils.specimen_ids('Stool')} THEN 'Other stool cultures'
              WHEN t.specimen_id IN #{report_utils.specimen_ids('Swabs')} THEN 'Other swabs culture'
              WHEN t.specimen_id IN #{report_utils.specimen_ids('HVS')} THEN 'HVS Culture'
              WHEN t.specimen_id IN #{report_utils.specimen_ids('CSF')} THEN 'Number of CSF cultures done'
              ELSE 'Unknown'
            END AS indicator,
            MONTHNAME(t.created_date) AS month,
            COUNT(DISTINCT t.id) AS total,
            GROUP_CONCAT(DISTINCT t.id) AS associated_ids
          FROM tests t
                  INNER JOIN
              test_type_indicator_mappings ttim ON ttim.test_types_id = t.test_type_id
                  INNER  JOIN
              test_indicators ti ON ti.id = ttim.test_indicators_id
                  INNER JOIN
              test_results tr ON tr.test_indicator_id = ti.id
                  AND tr.test_id = t.id
                  AND tr.voided = 0
          WHERE
              t.test_type_id IN #{report_utils.test_type_ids('Cuture & Sensitivity')}
                  AND YEAR(t.created_date) = #{year}
                  AND t.status_id IN (4 , 5)
                  AND t.voided = 0
                  AND tr.value IS NOT NULL
          GROUP BY MONTHNAME(t.created_date), indicator
        SQL
      end

      def cholera_rapid_diagnostic_done
        ActiveRecord::Base.connection.execute('SET SESSION group_concat_max_len = 1000000')
        Report.find_by_sql <<~SQL
          SELECT 'Cholera Rapid Diagnostic test done' AS indicator,
            MONTHNAME(t.created_date) AS month,
            COUNT(DISTINCT t.id) AS total,
            GROUP_CONCAT(DISTINCT t.id) AS associated_ids
          FROM tests t
                  INNER JOIN
              test_type_indicator_mappings ttim ON ttim.test_types_id = t.test_type_id
                  INNER  JOIN
              test_indicators ti ON ti.id = ttim.test_indicators_id
                  INNER JOIN
              test_results tr ON tr.test_indicator_id = ti.id
                  AND tr.test_id = t.id
                  AND tr.voided = 0
          WHERE
              t.test_type_id IN #{report_utils.test_type_ids('Cholera')}
              AND ti.id IN #{report_utils.test_indicator_ids('Cholera')}
                  AND YEAR(t.created_date) = #{year}
                  AND t.status_id IN (4 , 5)
                  AND t.voided = 0
                  AND tr.value IS NOT NULL
          GROUP BY MONTHNAME(t.created_date), indicator
        SQL
      end

      def cholera_rapid_diagonostic_positive
        ActiveRecord::Base.connection.execute('SET SESSION group_concat_max_len = 1000000')
        Report.find_by_sql <<~SQL
          SELECT
            'Positive Cholera Rapid Diagnostic test' AS indicator,
            MONTHNAME(t.created_date) AS month,
            COUNT(DISTINCT t.id) AS total,
            GROUP_CONCAT(DISTINCT t.id) AS associated_ids
          FROM tests t
                  INNER JOIN
              test_type_indicator_mappings ttim ON ttim.test_types_id = t.test_type_id
                  INNER  JOIN
              test_indicators ti ON ti.id = ttim.test_indicators_id
                  INNER JOIN
              test_results tr ON tr.test_indicator_id = ti.id
                  AND tr.test_id = t.id
                  AND tr.voided = 0
          WHERE
              t.test_type_id IN #{report_utils.test_type_ids('Cholera')}
                AND ti.id IN #{report_utils.test_indicator_ids('Cholera')}
                AND YEAR(t.created_date) = #{year}
                AND t.status_id IN (4 , 5)
                AND t.voided = 0
                AND tr.value IS NOT NULL
                AND tr.value = 'Positive'
          GROUP BY MONTHNAME(t.created_date)
        SQL
      end

      def cholera_culture
        ActiveRecord::Base.connection.execute('SET SESSION group_concat_max_len = 1000000')
        Report.find_by_sql <<~SQL
          SELECT 'Cholera cultures done' AS indicator,
            MONTHNAME(t.created_date) AS month,
            COUNT(DISTINCT t.id) AS total,
            GROUP_CONCAT(DISTINCT t.id) AS associated_ids
          FROM tests t
                  INNER JOIN
              test_type_indicator_mappings ttim ON ttim.test_types_id = t.test_type_id
                  INNER  JOIN
              test_indicators ti ON ti.id = ttim.test_indicators_id
                  INNER JOIN
              test_results tr ON tr.test_indicator_id = ti.id
                  AND tr.test_id = t.id
                  AND tr.voided = 0
          WHERE
              t.specimen_id IN #{report_utils.specimen_ids('Stool')}
              AND ti.id IN #{report_utils.test_indicator_ids('Culture')}
                  AND YEAR(t.created_date) = #{year}
                  AND t.status_id IN (4 , 5)
                  AND t.voided = 0
                  AND tr.value IS NOT NULL
          GROUP BY MONTHNAME(t.created_date), indicator
        SQL
      end

      def cholera_culture_positive
        ActiveRecord::Base.connection.execute('SET SESSION group_concat_max_len = 1000000')
        Report.find_by_sql <<~SQL
          SELECT
            'Positive cholera samples' AS indicator,
            MONTHNAME(t.created_date) AS month,
            COUNT(DISTINCT t.id) AS total,
            GROUP_CONCAT(DISTINCT t.id) AS associated_ids
          FROM tests t
                  INNER JOIN
              test_type_indicator_mappings ttim ON ttim.test_types_id = t.test_type_id
                  INNER  JOIN
              test_indicators ti ON ti.id = ttim.test_indicators_id
                  INNER JOIN
              test_results tr ON tr.test_indicator_id = ti.id
                  AND tr.test_id = t.id
                  AND tr.voided = 0
              INNER JOIN drug_susceptibilities ds ON ds.test_id = t.id
              INNER JOIN organisms o ON o.id = ds.organism_id
          WHERE
                  ti.id IN #{report_utils.test_indicator_ids('Culture')}
                  AND o.id IN #{report_utils.organism_ids('Cholera')}
                  AND YEAR(t.created_date) = #{year}
                  AND t.status_id IN (4 , 5)
                  AND t.voided = 0
                  AND tr.value IS NOT NULL
                  AND tr.value = 'Growth'
          GROUP BY MONTHNAME(t.created_date)
        SQL
      end

      def dna_eid_samples_received
        ActiveRecord::Base.connection.execute('SET SESSION group_concat_max_len = 1000000')
        Report.find_by_sql <<~SQL
          SELECT
            MONTHNAME(t.created_date) AS month,
            COUNT(DISTINCT t.id) AS total, 'DNA-EID samples received' AS indicator,
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
              t.test_type_id IN #{report_utils.test_type_ids('Early Infant Diagnosis')}
                  AND YEAR(t.created_date) = #{year}
                  AND t.status_id <> 1
                  AND t.voided = 0
                  AND tr.value NOT IN ('', '0')
                  AND tr.value IS NOT NULL
          GROUP BY MONTHNAME(t.created_date)
        SQL
      end

      def dna_eid_samples_done
        ActiveRecord::Base.connection.execute('SET SESSION group_concat_max_len = 1000000')
        Report.find_by_sql <<~SQL
          SELECT
            MONTHNAME(t.created_date) AS month,
            COUNT(DISTINCT t.id) AS total, 'DNA-EID tests done' AS indicator,
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
              t.test_type_id IN #{report_utils.test_type_ids('Early Infant Diagnosis')}
                  AND YEAR(t.created_date) = #{year}
                  AND t.status_id IN (4 , 5)
                  AND t.voided = 0
                  AND tr.value NOT IN ('', '0')
                  AND tr.value IS NOT NULL
          GROUP BY MONTHNAME(t.created_date)
        SQL
      end

      # Number with positive results
      def dna_eid_positive_results
        ActiveRecord::Base.connection.execute('SET SESSION group_concat_max_len = 1000000')
        Report.find_by_sql <<~SQL
          SELECT
            MONTHNAME(t.created_date) AS month,
            COUNT(DISTINCT t.id) AS total, 'Number with positive results' AS indicator,
            GROUP_CONCAT(DISTINCT t.id) AS associated_ids
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
              t.test_type_id IN #{report_utils.test_type_ids('Early Infant Diagnosis')}
                AND YEAR(t.created_date) = #{year}
                AND t.status_id IN (4 , 5)
                AND t.voided = 0
                AND tr.value IS NOT NULL
                AND tr.value NOT IN ('NO value', 'ERROR', 'INVALID', 'NEGATIVE', '', '0', 'h')
                AND tr.value NOT LIKE '%NOT%'
          GROUP BY MONTHNAME(t.created_date)
        SQL
      end

      def vl_samples_received
        ActiveRecord::Base.connection.execute('SET SESSION group_concat_max_len = 1000000')
        Report.find_by_sql <<~SQL
          SELECT
            MONTHNAME(t.created_date) AS month,
            COUNT(DISTINCT t.id) AS total, 'VL tests done' AS indicator,
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
            t.test_type_id IN #{report_utils.test_type_ids('Viral Load')}
              AND YEAR(t.created_date) = #{year}
              AND t.status_id <> 1
              AND t.voided = 0
          GROUP BY MONTHNAME(t.created_date)
        SQL
      end

      def vl_tests_done
        ActiveRecord::Base.connection.execute('SET SESSION group_concat_max_len = 1000000')
        Report.find_by_sql <<~SQL
          SELECT
            MONTHNAME(t.created_date) AS month,
            COUNT(DISTINCT t.id) AS total, 'VL tests done' AS indicator,
            GROUP_CONCAT(DISTINCT t.id) AS associated_ids
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
              t.test_type_id IN #{report_utils.test_type_ids('Early Infant Diagnosis')}
                AND YEAR(t.created_date) = #{year}
                AND t.status_id IN (4 , 5)
                AND t.voided = 0
                AND tr.value IS NOT NULL
                AND tr.value NOT IN ('NO value', 'ERROR', 'INVALID', 'NEGATIVE', '', '0', 'h')
                AND tr.value NOT LIKE '%NOT%'
          GROUP BY MONTHNAME(t.created_date)
        SQL
      end

      # VL results with less than 1000 copies per ml
      def vl_results_less_100copies_permil
        ActiveRecord::Base.connection.execute('SET SESSION group_concat_max_len = 1000000')
        Report.find_by_sql <<~SQL
          SELECT
            MONTHNAME(t.created_date) AS month,
            COUNT(DISTINCT t.id) AS total, 'VL results with less than 1000 copies per ml' AS indicator,
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
            t.test_type_id IN #{report_utils.test_type_ids('Early Infant Diagnosis')}
              AND YEAR(t.created_date) = #{year}
              AND t.status_id IN (4 , 5)
              AND t.voided = 0
              AND tr.value IS NOT NULL
              AND REPLACE(tr.value, ',', '') < 1000
              AND REPLACE(REPLACE(tr.value, ',', '') , ' ', '') < 1000
              AND REPLACE(REPLACE(tr.value, '<', ''), ' ', '') < 1000
              AND REPLACE(tr.value,' ', '') < 1000
              AND tr.value NOT IN ('NO RESULT', 'ERROR', 'INVALID')
          GROUP BY MONTHNAME(t.created_date)
        SQL
      end

      # Number of CSF samples analysed
      def csf_samples_analysed
        ActiveRecord::Base.connection.execute('SET SESSION group_concat_max_len = 1000000')
        Report.find_by_sql <<~SQL
            SELECT
              MONTHNAME(t.created_date) AS month,
              COUNT(DISTINCT t.order_id) AS total, 'Number of CSF samples analysed' AS indicator,
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
            t.specimen_id IN #{report_utils.specimen_ids('CSF')}
              AND YEAR(t.created_date) = #{year}
              AND t.status_id IN (4 , 5)
              AND t.voided = 0
              AND tr.value NOT IN ('' , '0')
              AND tr.value IS NOT NULL
            GROUP BY MONTHNAME(t.created_date)
        SQL
      end

      # Number of CSF samples analysed for AFB
      def csf_samples_analysed_afb
        ActiveRecord::Base.connection.execute('SET SESSION group_concat_max_len = 1000000')
        Report.find_by_sql <<~SQL
            SELECT
              MONTHNAME(t.created_date) AS month,
              COUNT(DISTINCT t.id) AS total, 'Number of CSF samples analysed for AFB' AS indicator,
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
            t.specimen_id IN #{report_utils.specimen_ids('CSF')}
              AND t.test_type_id IN #{report_utils.test_type_ids('TB Tests')}
              AND YEAR(t.created_date) = #{year}
              AND t.status_id IN (4 , 5)
              AND t.voided = 0
              AND tr.value NOT IN ('', '0')
              AND tr.value IS NOT NULL
            GROUP BY MONTHNAME(t.created_date)
        SQL
      end

      # Number of CSF samples with Organism
      def csf_samples_organism
        ActiveRecord::Base.connection.execute('SET SESSION group_concat_max_len = 1000000')
        Report.find_by_sql <<~SQL
            SELECT
              MONTHNAME(t.created_date) AS month,
              COUNT(DISTINCT t.id) AS total, 'Number of CSF samples with Organism' AS indicator,
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
            t.specimen_id IN #{report_utils.specimen_ids('CSF')}
              AND YEAR(t.created_date) = #{year}
              AND t.status_id IN (4 , 5)
              AND t.voided = 0
              AND tr.value NOT IN ('', '0')
              AND (tr.value IN ('seen', 'growth') OR tr.value LIKE '%positive%')
              AND tr.value IS NOT NULL
            GROUP BY MONTHNAME(t.created_date)
        SQL
      end

      def india_ink_tests_done
        ActiveRecord::Base.connection.execute('SET SESSION group_concat_max_len = 1000000')
        Report.find_by_sql <<~SQL
            SELECT
              MONTHNAME(t.created_date) AS month,
              COUNT(DISTINCT t.id) AS total, 'Total India ink done' AS indicator,
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
            t.test_type_id IN #{report_utils.test_type_ids('India Ink')}
              AND YEAR(t.created_date) = #{year}
              AND t.status_id IN (4 , 5)
              AND t.voided = 0
              AND tr.value IS NOT NULL
              AND tr.value NOT IN ('', '0')
            GROUP BY MONTHNAME(t.created_date)
        SQL
      end

      def india_link_positive
        ActiveRecord::Base.connection.execute('SET SESSION group_concat_max_len = 1000000')
        Report.find_by_sql <<~SQL
            SELECT
              MONTHNAME(t.created_date) AS month,
              COUNT(DISTINCT t.id) AS total, 'India ink positive' AS indicator,
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
            t.test_type_id IN #{report_utils.test_type_ids('India Ink')}
              AND YEAR(t.created_date) = #{year}
              AND t.status_id IN (4 , 5)
              AND t.voided = 0
              AND tr.value IS NOT NULL
              AND tr.value = 'Positive'
              AND tr.value NOT IN ('', '0')
            GROUP BY MONTHNAME(t.created_date)
        SQL
      end

      def gram_stain_done
        ActiveRecord::Base.connection.execute('SET SESSION group_concat_max_len = 1000000')
        Report.find_by_sql <<~SQL
            SELECT
              MONTHNAME(t.created_date) AS month,
              COUNT(DISTINCT t.id) AS total, 'Total Gram stain done' AS indicator,
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
            t.test_type_id IN #{report_utils.test_type_ids('Gram Stain')}
              AND YEAR(t.created_date) = #{year}
              AND t.status_id IN (4 , 5)
              AND t.voided = 0
              AND tr.value IS NOT NULL
              AND tr.value NOT IN ('', '0')
            GROUP BY MONTHNAME(t.created_date)
        SQL
      end

      def gram_stain_positive
        ActiveRecord::Base.connection.execute('SET SESSION group_concat_max_len = 1000000')
        Report.find_by_sql <<~SQL
            SELECT
              MONTHNAME(t.created_date) AS month,
              COUNT(DISTINCT t.id) AS total, 'Gram stain positive' AS indicator,
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
            t.test_type_id IN #{report_utils.test_type_ids('Gram Stain')}
              AND YEAR(t.created_date) = #{year}
              AND t.status_id IN (4 , 5)
              AND t.voided = 0
              AND tr.value IS NOT NULL
              AND tr.value LIKE '%Positive%'
              AND tr.value NOT IN ('', '0')
            GROUP BY MONTHNAME(t.created_date)
        SQL
      end

      def hvs_analysed
        ActiveRecord::Base.connection.execute('SET SESSION group_concat_max_len = 1000000')
        Report.find_by_sql <<~SQL
            SELECT
              MONTHNAME(t.created_date) AS month,
              COUNT(DISTINCT t.id) AS total, 'HVS analysed' AS indicator,
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
            t.specimen_id IN #{report_utils.specimen_ids('HVS')}
              AND YEAR(t.created_date) = #{year}
              AND t.status_id IN (4 , 5)
              AND t.voided = 0
              AND tr.value IS NOT NULL
              AND tr.value NOT IN ('', '0')
            GROUP BY MONTHNAME(t.created_date)
        SQL
      end

      def hvs_organism
        ActiveRecord::Base.connection.execute('SET SESSION group_concat_max_len = 1000000')
        Report.find_by_sql <<~SQL
            SELECT
              MONTHNAME(t.created_date) AS month,
              COUNT(DISTINCT t.id) AS total, 'HVS with organism' AS indicator,
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
            t.specimen_id IN #{report_utils.specimen_ids('HVS')}
              AND YEAR(t.created_date) = #{year}
              AND t.status_id IN (4 , 5)
              AND t.voided = 0
              AND tr.value IS NOT NULL
              AND (tr.value IN ('seen', 'growth') OR tr.value LIKE '%positive%')
              AND tr.value NOT IN ('', '0')
            GROUP BY MONTHNAME(t.created_date)
        SQL
      end

      def cryptococcal_antigen_tests
        ActiveRecord::Base.connection.execute('SET SESSION group_concat_max_len = 1000000')
        Report.find_by_sql <<~SQL
            SELECT
              MONTHNAME(t.created_date) AS month,
              COUNT(DISTINCT t.id) AS total, 'Cryptococcal antigen test' AS indicator,
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
            t.test_type_id IN #{report_utils.test_type_ids('Cryptococcus Antigen Test')}
              AND YEAR(t.created_date) = #{year}
              AND t.status_id IN (4 , 5)
              AND t.voided = 0
              AND tr.value IS NOT NULL
              AND tr.value NOT IN ('', '0')
            GROUP BY MONTHNAME(t.created_date)
        SQL
      end

      def positive_cryptococcal_antigen_tests
        ActiveRecord::Base.connection.execute('SET SESSION group_concat_max_len = 1000000')
        Report.find_by_sql <<~SQL
            SELECT
              MONTHNAME(t.created_date) AS month,
              COUNT(DISTINCT t.id) AS total, 'Cryptococcal antigen test Positive' AS indicator,
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
            t.test_type_id IN #{report_utils.test_type_ids('Cryptococcus Antigen Test')}
              AND YEAR(t.created_date) = #{year}
              AND t.status_id IN (4 , 5)
              AND t.voided = 0
              AND tr.value IS NOT NULL
              AND tr.value = 'Positive'
              AND tr.value NOT IN ('', '0')
            GROUP BY MONTHNAME(t.created_date)
        SQL
      end

      def serum_crag
        ActiveRecord::Base.connection.execute('SET SESSION group_concat_max_len = 1000000')
        Report.find_by_sql <<~SQL
            SELECT
              MONTHNAME(t.created_date) AS month,
              COUNT(DISTINCT t.id) AS total, 'Serum Crag' AS indicator,
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
            (t.test_type_id IN #{report_utils.test_type_ids('Serum CrAg')} OR t.test_type_id IN #{report_utils.test_type_ids('Cryptococcus Antigen Test')})
            AND t.specimen_id IN #{report_utils.specimen_ids('Blood')}
              AND YEAR(t.created_date) = #{year}
              AND t.status_id IN (4 , 5)
              AND t.voided = 0
              AND tr.value IS NOT NULL
              AND tr.value NOT IN ('', '0')
            GROUP BY MONTHNAME(t.created_date)
        SQL
      end

      def positive_serum_crag
        ActiveRecord::Base.connection.execute('SET SESSION group_concat_max_len = 1000000')
        Report.find_by_sql <<~SQL
            SELECT
              MONTHNAME(t.created_date) AS month,
              COUNT(DISTINCT t.id) AS total, 'Serum Crag Positive' AS indicator,
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
            (t.test_type_id IN #{report_utils.test_type_ids('Serum CrAg')} OR t.test_type_id IN #{report_utils.test_type_ids('Cryptococcus Antigen Test')})
            AND t.specimen_id IN #{report_utils.specimen_ids('Blood')}
              AND YEAR(t.created_date) = #{year}
              AND t.status_id IN (4 , 5)
              AND t.voided = 0
              AND tr.value IS NOT NULL
              AND tr.value = 'Positive'
              AND tr.value NOT IN ('', '0')
            GROUP BY MONTHNAME(t.created_date)
        SQL
      end

      def fluids_analysed
        ActiveRecord::Base.connection.execute('SET SESSION group_concat_max_len = 1000000')
        Report.find_by_sql <<~SQL
            SELECT
              MONTHNAME(t.created_date) AS month,
              COUNT(DISTINCT t.order_id) AS total, 'Total number of fluids analysed' AS indicator,
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
            t.specimen_id IN #{report_utils.specimen_ids_like('Fluid')}
              AND YEAR(t.created_date) = #{year}
              AND t.status_id IN (4 , 5)
              AND t.voided = 0
              AND tr.value IS NOT NULL
              AND tr.value NOT IN ('', '0')
            GROUP BY MONTHNAME(t.created_date)
        SQL
      end

      def other_swabs_analysed
        ActiveRecord::Base.connection.execute('SET SESSION group_concat_max_len = 1000000')
        Report.find_by_sql <<~SQL
            SELECT
              MONTHNAME(t.created_date) AS month,
              COUNT(DISTINCT t.id) AS total, 'Other swabs analysed' AS indicator,
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
            t.specimen_id IN #{report_utils.specimen_ids('Swabs')}
              AND YEAR(t.created_date) = #{year}
              AND t.status_id IN (4 , 5)
              AND t.voided = 0
              AND tr.value IS NOT NULL
              AND tr.value NOT IN ('', '0')
            GROUP BY MONTHNAME(t.created_date)
        SQL
      end

      def other_swabs_organism
        ActiveRecord::Base.connection.execute('SET SESSION group_concat_max_len = 1000000')
        Report.find_by_sql <<~SQL
            SELECT
              MONTHNAME(t.created_date) AS month,
              COUNT(DISTINCT t.id) AS total, 'Other swabs with organism' AS indicator,
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
            t.specimen_id IN #{report_utils.specimen_ids('Swabs')}
              AND YEAR(t.created_date) = #{year}
              AND t.status_id IN (4 , 5)
              AND t.voided = 0
              AND tr.value IS NOT NULL
              AND (tr.value IN ('seen', 'growth', 'AFB SEEN  SCANTY','Scanty AAFB seen') OR tr.value LIKE '%positive%')
              AND tr.value NOT IN ('', '0')
            GROUP BY MONTHNAME(t.created_date)
        SQL
      end

      def report_utils
        Reports::Moh::ReportUtils
      end
    end
  end
end
