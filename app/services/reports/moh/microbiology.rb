# frozen_string_literal: true

# Module defines methods for Microbiology generating reports
module Reports
  # Generates Microbiology reports
  module Moh
    # Microbiology reports
    class Microbiology < BaseReport
      attr_reader :report, :report_indicator
      attr_accessor :year

      def initialize
        super
        @report = {}
        @report_indicator = REPORT_INDICATORS
        initialize_report_counts
      end

      def generate_report
        data = Report.where(year:, name: 'moh_microbiology').first&.data
        return data if data.present?

        report_data = number_of_afb_examined + new_tb_cases_examined + positive_new_tb_cases_examined + total_tb_lam +
                      total_pos_tb_lam + rif_resistance_detected + mtb_not_detected + mtb_detected + rif_resistance_not_detected +
                      rif_resistance_indeterminate + no_results + invalid + covid_tests_performed +
                      covid_tests_positive_results + covid_tests_invalid_results + covid_tests_no_results +
                      covid_tests_error_results + dna_eid_samples_received + dna_eid_positive_results +
                      vl_samples_received + vl_tests_done + vl_results_less_100copies_permil + csf_samples_analysed +
                      other_sterile_fluids_analysed + urine_samples_analysed + blood_samples_analysed +
                      pus_wound_swabs_analysed + hvs_samples_analysed + sputum_samples_analysed +
                      stool_samples_analysed + total_bacteriology_samples_analysed + other_samples_analysed + csf_samples_analysed_afb + csf_samples_analysed_afb + india_ink_tests_done +
                      csf_samples_organism + india_link_positive + gram_stain_done + gram_stain_positive +
                      gram_stain_by_specimen + hvs_analysed + hvs_organism + cryptococcal_antigen_tests + positive_cryptococcal_antigen_tests +
                      serum_crag + positive_serum_crag + other_swabs_analysed + other_swabs_organism + fluids_analysed +
                      culture + positive_culture + swab_positive_culture + cholera_culture + cholera_culture_positive +
                      cholera_rapid_diagnostic_done + cholera_rapid_diagonostic_positive + total_cultures_done +
                      total_cultures_with_growth + total_cultures_with_na_result_value + total_cultures_with_no_growth + total_cultures_with_mixed_growth +
                      total_cultures_with_growth_of_normal_flora + total_cultures_with_growth_of_contaminants +
                      total_cultures_with_growth_of_yeast_cells + total_ast_done + csf_ast_organisms + tb_tests_done
        data = update_report_counts(report_data)
        data = calculate_ast_percentages(data)
        Report.find_or_create_by(name: 'moh_microbiology', year:).update(data:)
        data
      end

      private

      REPORT_INDICATORS = [
        # A- TOTAL NUMBER OF SAMPLES ANALYSED - Daily total number of all bacteriology samples analysed
        'Total Number of bacteriology samples analysed',
        'Total number of CSF samples analysed',
        'Total number of Other Sterile Fluids analysed',
        'Total number of Urine samples analysed for culture and sensitivity',
        'Total number of Blood samples analysed for culture and sensitivity',
        'Total number of Pus/Wound swabs analysed for culture and sensitivity',
        'Total number of HVS samples analysed for culture and sensitivity',
        'Total number of Sputum samples analysed for culture and sensitivity',
        'Total number of Stool samples analysed for culture and sensitivity',
        'Total number of Other samples analysed',

        # B- CULTURE (General Counts)
        'Total number of Cultures done',
        'Total number of Cultures with growth',
        'Total number of Cultures with no growth',
        'Total number of Cultures with mixed growth (no predominant organism)',
        'Total number of Cultures with growth of normal flora',
        'Total number of Cultures with growth of contaminants',
        'Total number of Cultures with growth of Yeast Cells',
        'Total number of Cultures with other growth results values',
        'Total number of AST done',

        # C- PATHOGENIC ORGANISMS BASED ON SAMPLES
        # E.Coli
        'E.Coli Isolated from CSF',
        'E.Coli Isolated from other sterile fluids except CSF',
        'E.Coli Isolated from Urine',
        'E.Coli Isolated from Blood',
        'E.Coli Isolated from Pus',
        'E.Coli Isolated from HVS',
        'E.Coli Isolated from Stool',
        'E.Coli Isolated from Other Samples',

        # Klebsiella Spp
        'Klebsiella Spp Isolated from CSF',
        'Klebsiella Spp Isolated from other sterile fluids except CSF',
        'Klebsiella Spp Isolated from Urine',
        'Klebsiella Spp Isolated from Blood',
        'Klebsiella Spp Isolated from Pus',
        'Klebsiella Spp Isolated from HVS',
        'Klebsiella Spp Isolated from Stool',
        'Klebsiella Spp Isolated from Other Samples',

        # Acinetobacter Spp
        'Acinetobacter Spp Isolated from CSF',
        'Acinetobacter Spp Isolated from other sterile fluids except CSF',
        'Acinetobacter Spp Isolated from Urine',
        'Acinetobacter Spp Isolated from Blood',
        'Acinetobacter Spp Isolated from Pus',
        'Acinetobacter Spp Isolated from HVS',
        'Acinetobacter Spp Isolated from Stool',
        'Acinetobacter Spp Isolated from Other Samples',

        # Proteus Spp
        'Proteus Spp Isolated from CSF',
        'Proteus Spp Isolated from other sterile fluids except CSF',
        'Proteus Spp Isolated from Urine',
        'Proteus Spp Isolated from Blood',
        'Proteus Spp Isolated from Pus',
        'Proteus Spp Isolated from HVS',
        'Proteus Spp Isolated from Other Samples',

        # Salmonella Spp
        'Salmonella Spp Isolated from CSF',
        'Salmonella Spp Isolated from other sterile fluids except CSF',
        'Salmonella Spp Isolated from Urine',
        'Salmonella Spp Isolated from Blood',
        'Salmonella Spp Isolated from Pus',
        'Salmonella Spp Isolated from HVS',
        'Salmonella Spp Isolated from Stool',
        'Salmonella Spp Isolated from Other Samples',

        # Pseudomonas Spp
        'Pseudomonas Spp Isolated from CSF',
        'Pseudomonas Spp Isolated from other sterile fluids except CSF',
        'Pseudomonas Spp Isolated from Urine',
        'Pseudomonas Spp Isolated from Blood',
        'Pseudomonas Spp Isolated from Pus',
        'Pseudomonas Spp Isolated from HVS',
        'Pseudomonas Spp Isolated from Stool',
        'Pseudomonas Spp Isolated from Other Samples',

        # Strept pneumoniae
        'Strept pneumoniae Isolated from CSF',
        'Strept pneumoniae Isolated from other sterile fluids except CSF',
        'Strept pneumoniae Isolated from Urine',
        'Strept pneumoniae Isolated from Blood',
        'Strept pneumoniae Isolated from Pus',
        'Strept pneumoniae Isolated from HVS',
        'Strept pneumoniae Isolated from Other Samples',

        # Enterococcus spp
        'Enterococcus spp Isolated from CSF',
        'Enterococcus spp Isolated from other sterile fluids except CSF',
        'Enterococcus spp Isolated from Urine',
        'Enterococcus spp Isolated from Blood',
        'Enterococcus spp Isolated from Pus',
        'Enterococcus spp Isolated from HVS',
        'Enterococcus spp Isolated from Other Samples',

        # Strep spp (A,B)
        'Strep spp (A,B) Isolated from CSF',
        'Strep spp (A,B) Isolated from other sterile fluids except CSF',
        'Strep spp (A,B) Isolated from Urine',
        'Strep spp (A,B) Isolated from Blood',
        'Strep spp (A,B) Isolated from Pus',
        'Strep spp (A,B) Isolated from HVS',
        'Strep spp (A,B) Isolated from Stool',
        'Strep spp (A,B) Isolated from Other Samples',

        # Staphylcoccus Aureus
        'Staphylcoccus Aureus Isolated from CSF',
        'Staphylcoccus Aureus Isolated from other sterile fluids except CSF',
        'Staphylcoccus Aureus Isolated from Urine',
        'Staphylcoccus Aureus Isolated from Blood',
        'Staphylcoccus Aureus Isolated from Pus',
        'Staphylcoccus Aureus Isolated from HVS',
        'Staphylcoccus Aureus Isolated from Other Samples',

        # Neisseria spp
        'Neisseria spp Isolated from CSF',
        'Neisseria spp Isolated from other sterile fluids except CSF',
        'Neisseria spp Isolated from Urine',
        'Neisseria spp Isolated from Blood',
        'Neisseria spp Isolated from Pus',
        'Neisseria spp Isolated from HVS',
        'Neisseria spp Isolated from Other Samples',

        # Shigella Spp
        'Shigella Spp Isolated from Blood',
        'Shigella Spp Isolated from Stool',
        'Shigella Spp Isolated from Other Samples',

        # Cryptococcal Spp
        'Cryptococcal Spp Isolated from CSF',
        'Cryptococcal Spp Isolated from other sterile fluids except CSF',

        # TB Tests
        'TB Tests done on CSF',
        'TB Tests done on other sterile fluids except CSF',
        'TB Tests done on Urine',
        'TB Tests done on Pus',
        'TB Tests done on Stool',
        'TB Tests done on Sputum',
        'TB Tests done on Other TB Samples',

        # Other Spp
        'Other Spp Isolated from CSF',
        'Other Spp Isolated from other sterile fluids except CSF',
        'Other Spp Isolated from Urine',
        'Other Spp Isolated from Blood',
        'Other Spp Isolated from Pus',
        'Other Spp Isolated from HVS',
        'Other Spp Isolated from Stool',
        'Other Spp Isolated from Other Samples',

        # D- ANTIMICROBIAL SUSCEPTIBILITY TESTING (AST)
        'Amoxicillin/Clavulanic Acid # of Tests Done',
        'Amoxicillin/Clavulanic Acid Sensitive (%)',
        'Amoxicillin/Clavulanic Acid Intermediate (%)',
        'Amoxicillin/Clavulanic Acid Resistant (%)',

        'Ampicillin # of Tests Done',
        'Ampicillin Sensitive (%)',
        'Ampicillin Intermediate (%)',
        'Ampicillin Resistant (%)',

        'Piperacillin/Tazobactum # of Tests Done',
        'Piperacillin/Tazobactum Sensitive (%)',
        'Piperacillin/Tazobactum Intermediate (%)',
        'Piperacillin/Tazobactum Resistant (%)',

        'Cefoxitin # of Tests Done',
        'Cefoxitin Sensitive (%)',
        'Cefoxitin Intermediate (%)',
        'Cefoxitin Resistant (%)',

        'Ceftriaxone # of Tests Done',
        'Ceftriaxone Sensitive (%)',
        'Ceftriaxone Intermediate (%)',
        'Ceftriaxone Resistant (%)',

        'Ceftazidime # of Tests Done',
        'Ceftazidime Sensitive (%)',
        'Ceftazidime Intermediate (%)',
        'Ceftazidime Resistant (%)',

        'Cefotaxime # of Tests Done',
        'Cefotaxime Sensitive (%)',
        'Cefotaxime Intermediate (%)',
        'Cefotaxime Resistant (%)',

        'Meropenem # of Tests Done',
        'Meropenem Sensitive (%)',
        'Meropenem Intermediate (%)',
        'Meropenem Resistant (%)',

        'Ciplofloxacin # of Tests Done',
        'Ciplofloxacin Sensitive (%)',
        'Ciplofloxacin Intermediate (%)',
        'Ciplofloxacin Resistant (%)',

        'Gentamicin # of Tests Done',
        'Gentamicin Sensitive (%)',
        'Gentamicin Intermediate (%)',
        'Gentamicin Resistant (%)',

        'Tobramycin # of Tests Done',
        'Tobramycin Sensitive (%)',
        'Tobramycin Intermediate (%)',
        'Tobramycin Resistant (%)',

        'Vancomycin # of Tests Done',
        'Vancomycin Sensitive (%)',
        'Vancomycin Intermediate (%)',
        'Vancomycin Resistant (%)',

        'Erythromycin # of Tests Done',
        'Erythromycin Sensitive (%)',
        'Erythromycin Intermediate (%)',
        'Erythromycin Resistant (%)',

        'Amikacin # of Tests Done',
        'Amikacin Sensitive (%)',
        'Amikacin Intermediate (%)',
        'Amikacin Resistant (%)',

        # Gram Stain (from definitions)
        'Gram Stain CSF',
        'Gram Stain Other Sterile Fluids',
        'Gram Stain Blood',
        'Gram Stain Pus/Wound swabs',
        'Gram Stain High Vaginal swabs (HVS)',
        'Gram Stain Sputum',
        'Gram Stain Other Samples',

        # Additional indicators not in definitions (kept at the end)
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
        update_report_counts_optimized(counts, 'Microbiology')
      end

      # Calculate AST percentages for antibiotics
      def calculate_ast_percentages(data)
        return data unless data.is_a?(Hash)

        antibiotics_config = [
          { name: 'Amoxicillin/Clavulanic Acid', method: :amoxicillin_clavulanic_acid_ids },
          { name: 'Ampicillin', method: :ampicillin_ids },
          { name: 'Piperacillin/Tazobactum', method: :piperacillin_tazobactum_ids },
          { name: 'Cefoxitin', method: :cefoxitin_ids },
          { name: 'Ceftriaxone', method: :ceftriaxone_ids },
          { name: 'Ceftazidime', method: :ceftazidime_ids },
          { name: 'Cefotaxime', method: :cefotaxime_ids },
          { name: 'Meropenem', method: :meropenem_ids },
          { name: 'Ciplofloxacin', method: :ciplofloxacin_ids },
          { name: 'Gentamicin', method: :gentamicin_ids },
          { name: 'Tobramycin', method: :tobramycin_ids },
          { name: 'Vancomycin', method: :vancomycin_ids },
          { name: 'Erythromycin', method: :erythromycin_ids },
          { name: 'Amikacin', method: :amikacin_ids }
        ]

        data.each do |month, indicators|
          next unless indicators.is_a?(Hash)

          antibiotics_config.each do |antibiotic|
            drug_ids = send(antibiotic[:method])
            # Get the total tests done for this antibiotic in this month
            total_tests = ast_tests_for_antibiotic(drug_ids, month)
            sensitive_count = ast_susceptibility_count(drug_ids, month, 'Sensitive')
            intermediate_count = ast_susceptibility_count(drug_ids, month, 'Intermediate')
            resistant_count = ast_susceptibility_count(drug_ids, month, 'Resistant')

            # Calculate percentages
            sensitive_percent = total_tests.positive? ? ((sensitive_count.to_f / total_tests) * 100).round(2) : 0
            intermediate_percent = total_tests.positive? ? ((intermediate_count.to_f / total_tests) * 100).round(2) : 0
            resistant_percent = total_tests.positive? ? ((resistant_count.to_f / total_tests) * 100).round(2) : 0

            # Update the report with calculated values
            data[month]["#{antibiotic[:name]} # of Tests Done".to_sym] = {
              count: total_tests,
              associated_ids: ''
            }
            data[month]["#{antibiotic[:name]} Sensitive (%)".to_sym] = {
              count: sensitive_percent,
              associated_ids: ''
            }
            data[month]["#{antibiotic[:name]} Intermediate (%)".to_sym] = {
              count: intermediate_percent,
              associated_ids: ''
            }
            data[month]["#{antibiotic[:name]} Resistant (%)".to_sym] = {
              count: resistant_percent,
              associated_ids: ''
            }
          end
        end

        data
      end

      # Get total AST tests done for a specific antibiotic in a given month
      def ast_tests_for_antibiotic(drug_ids, month_name)
        result = ActiveRecord::Base.connection.execute(<<~SQL)
          SELECT COUNT(DISTINCT ds.id) AS total
          FROM drug_susceptibilities ds
            INNER JOIN drugs d ON d.id = ds.drug_id
            INNER JOIN tests t ON t.id = ds.test_id
          WHERE d.id IN #{drug_ids}
            AND t.test_type_id IN #{GlobalService.fetch_ids(TestType, ['Culture and Sensitivity'], %w[NLIMS_TT_0004_MWI])}
            AND YEAR(t.created_date) = #{year}
            AND LOWER(MONTHNAME(t.created_date)) = '#{month_name}'
            AND t.status_id IN (4, 5)
            AND t.voided = 0
            AND ds.voided = 0
            AND ds.interpretation IS NOT NULL
            AND ds.interpretation NOT IN ('', '0')
        SQL
        result.first.is_a?(Hash) ? result.first['total'] : result.first[0]
      end

      # Get count of AST tests with specific susceptibility result for an antibiotic in a given month
      def ast_susceptibility_count(drug_ids, month_name, susceptibility)
        # Map susceptibility to both old and new formats
        susceptibility_conditions = case susceptibility
                                    when 'Sensitive'
                                      "ds.interpretation IN ('S', 'S - Sensitive')"
                                    when 'Intermediate'
                                      "ds.interpretation IN ('I', 'I - Intermediate')"
                                    when 'Resistant'
                                      "ds.interpretation IN ('R', 'R - Resistant')"
                                    else
                                      "ds.interpretation = '#{susceptibility}'"
                                    end

        result = ActiveRecord::Base.connection.execute(<<~SQL)
          SELECT COUNT(DISTINCT ds.id) AS total
          FROM drug_susceptibilities ds
            INNER JOIN drugs d ON d.id = ds.drug_id
            INNER JOIN tests t ON t.id = ds.test_id
          WHERE d.id IN #{drug_ids}
            AND t.test_type_id IN #{GlobalService.fetch_ids(TestType, ['Culture and Sensitivity'], %w[NLIMS_TT_0004_MWI])}
            AND YEAR(t.created_date) = #{year}
            AND LOWER(MONTHNAME(t.created_date)) = '#{month_name}'
            AND t.status_id IN (4, 5)
            AND t.voided = 0
            AND ds.voided = 0
            AND #{susceptibility_conditions}
        SQL
        result.first.is_a?(Hash) ? result.first['total'] : result.first[0]
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
              t.test_type_id IN #{GlobalService.fetch_ids(TestType, ['TB Tests'], ['NLIMS_TT_0010_MWI'])}
                  AND ti.id IN #{GlobalService.fetch_ids(TestIndicator, ['Smear Microscopy', 'Smear microscopy result'], ['NLIMS_TI_0201_MWI'])}
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
              t.test_type_id IN #{GlobalService.fetch_ids(TestType, ['TB Tests', 'GeneXpert Tests'], ['NLIMS_TT_0010_MWI'])}
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
              t.test_type_id IN #{GlobalService.fetch_ids(TestType, ['TB Tests'], ['NLIMS_TT_0010_MWI'])}
                  AND ti.id IN #{GlobalService.fetch_ids(TestIndicator, ['Smear Microscopy'], ['NLIMS_TI_0201_MWI'])}
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
              t.test_type_id IN #{GlobalService.fetch_ids(TestType, ['TB LAM', 'Tuberculosis Lipoarabinomannan'], ['NLIMS_TT_0121_MWI'])}
                  AND YEAR(t.created_date) = #{year}
                  AND t.status_id IN (4 , 5)
                  AND t.voided = 0
                  AND tr.value NOT IN ('', '0')
                  AND tr.value IS NOT NULL
          GROUP BY MONTHNAME(t.created_date)
        SQL
      end

      def total_pos_tb_lam
        ActiveRecord::Base.connection.execute('SET SESSION group_concat_max_len = 1000000')
        Report.find_by_sql <<~SQL
          SELECT
            MONTHNAME(t.created_date) AS month,
            COUNT(DISTINCT t.id) AS total, 'TB LAM Positive' AS indicator,
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
              t.test_type_id IN #{GlobalService.fetch_ids(TestType, ['TB LAM', 'Tuberculosis Lipoarabinomannan'], ['NLIMS_TT_0121_MWI'])}
                  AND YEAR(t.created_date) = #{year}
                  AND t.status_id IN (4 , 5)
                  AND t.voided = 0
                  AND tr.value NOT IN ('', '0')
                  AND tr.value IS NOT NULL
                  AND tr.value = 'Positive'
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
              t.test_type_id IN #{GlobalService.fetch_ids(TestType, ['TB Tests', 'GeneXpert Tests'], ['NLIMS_TT_0010_MWI'])}
                  AND ti.id IN #{GlobalService.fetch_ids(TestIndicator, ['GeneXpert MTB', 'Gene Xpert MTB'], ['NLIMS_TI_0202_MWI'])}
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
              t.test_type_id IN #{GlobalService.fetch_ids(TestType, ['TB Tests', 'GeneXpert Tests'], ['NLIMS_TT_0010_MWI'])}
                  AND ti.id IN #{GlobalService.fetch_ids(TestIndicator, ['GeneXpert MTB', 'Gene Xpert MTB'], ['NLIMS_TI_0202_MWI'])}
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
              t.test_type_id IN #{GlobalService.fetch_ids(TestType, ['TB Tests', 'GeneXpert Tests'], ['NLIMS_TT_0010_MWI'])}
                  AND ti.id IN #{GlobalService.fetch_ids(TestIndicator, ['GeneXpert RIF', 'Gene Xpert RIF Resistance'], ['NLIMS_TI_0203_MWI'])}
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
              t.test_type_id IN #{GlobalService.fetch_ids(TestType, ['TB Tests', 'GeneXpert Tests'], ['NLIMS_TT_0010_MWI'])}
                  AND ti.id IN #{GlobalService.fetch_ids(TestIndicator, ['GeneXpert RIF', 'Gene Xpert RIF Resistance'], ['NLIMS_TI_0203_MWI'])}
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
              t.test_type_id IN #{GlobalService.fetch_ids(TestType, ['TB Tests', 'GeneXpert Tests'], ['NLIMS_TT_0010_MWI'])}
                  AND ti.id IN #{GlobalService.fetch_ids(TestIndicator, ['GeneXpert RIF', 'Gene Xpert RIF Resistance'], ['NLIMS_TI_0203_MWI'])}
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
              t.test_type_id IN #{GlobalService.fetch_ids(TestType, ['TB Tests', 'GeneXpert Tests'], ['NLIMS_TT_0010_MWI'])}
                  AND ti.id IN #{GlobalService.fetch_ids(TestIndicator, ['GeneXpert MTB', 'Gene Xpert MTB'], ['NLIMS_TI_0202_MWI'])}
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
              t.test_type_id IN #{GlobalService.fetch_ids(TestType, ['TB Tests', 'GeneXpert Tests'], ['NLIMS_TT_0010_MWI'])}
                  AND ti.id IN #{GlobalService.fetch_ids(TestIndicator, ['GeneXpert MTB', 'Gene Xpert MTB'], ['NLIMS_TI_0202_MWI'])}
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
              t.test_type_id IN #{GlobalService.fetch_ids(TestType, ['COVID', 'COVID-19 Nucleic Acid Test', 'SARS COV-2 Rapid Antigen'], %w[NLIMS_TT_0120_MWI NLIMS_TT_0102_MWI])}
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
              t.test_type_id IN #{GlobalService.fetch_ids(TestType, ['COVID', 'COVID-19 Nucleic Acid Test', 'SARS COV-2 Rapid Antigen'], %w[NLIMS_TT_0120_MWI NLIMS_TT_0102_MWI])}
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
              t.test_type_id IN #{GlobalService.fetch_ids(TestType, ['COVID', 'COVID-19 Nucleic Acid Test', 'SARS COV-2 Rapid Antigen'], %w[NLIMS_TT_0120_MWI NLIMS_TT_0102_MWI])}
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
              t.test_type_id IN #{GlobalService.fetch_ids(TestType, ['COVID', 'COVID-19 Nucleic Acid Test', 'SARS COV-2 Rapid Antigen'], %w[NLIMS_TT_0120_MWI NLIMS_TT_0102_MWI])}
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
              t.test_type_id IN #{GlobalService.fetch_ids(TestType, ['COVID', 'COVID-19 Nucleic Acid Test', 'SARS COV-2 Rapid Antigen'], %w[NLIMS_TT_0120_MWI NLIMS_TT_0102_MWI])}
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
              WHEN t.specimen_id IN #{GlobalService.fetch_ids(Specimen, ['Urine'], %w[NLIMS_SP_0012_MWI])} THEN 'Urine culture Positive'
              WHEN t.specimen_id IN #{GlobalService.fetch_ids(Specimen, ['Stool'], %w[NLIMS_SP_0011_MWI])} THEN 'Stool samples with organisms isolated on culture'
              WHEN t.specimen_id IN #{GlobalService.fetch_ids(Specimen, ['Blood', 'Venous Whole Blood'], %w[NLIMS_SP_0003_MWI])} THEN 'Positive blood Cultures'
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
              t.test_type_id IN #{GlobalService.fetch_ids(TestType, ['Cuture & Sensitivity', 'Culture and Sensitivity'], %w[NLIMS_TT_0004_MWI])}
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
              WHEN t.specimen_id IN #{report_utils.specimen_ids_like('Swab')} THEN 'Other swabs culture Positive'
              WHEN t.specimen_id IN #{GlobalService.fetch_ids(Specimen, ['HVS'], ['NLIMS_SP_0008_MWI'])} THEN 'HVS Culture Positive'
              WHEN t.specimen_id IN #{GlobalService.fetch_ids(Specimen, ['CSF', 'Cerebrospinal Fluid'], %w[NLIMS_SP_0002_MWI])} THEN 'Positive CSF cultures'
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
              t.test_type_id IN #{GlobalService.fetch_ids(TestType, ['Cuture & Sensitivity', 'Culture and Sensitivity'], %w[NLIMS_TT_0004_MWI])}
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
              WHEN t.specimen_id IN #{GlobalService.fetch_ids(Specimen, ['Urine'], %w[NLIMS_SP_0012_MWI])} THEN 'Urine culture'
              WHEN t.specimen_id IN #{GlobalService.fetch_ids(Specimen, ['Blood', 'Venous Whole Blood'], %w[NLIMS_SP_0003_MWI])} THEN 'Number of Blood Cultures done'
              WHEN t.specimen_id IN #{GlobalService.fetch_ids(Specimen, ['Stool'], %w[NLIMS_SP_0011_MWI])} THEN 'Other stool cultures'
              WHEN t.specimen_id IN #{report_utils.specimen_ids_like('Swab')} THEN 'Other swabs culture'
              WHEN t.specimen_id IN #{GlobalService.fetch_ids(Specimen, ['HVS'], ['NLIMS_SP_0008_MWI'])} THEN 'HVS Culture'
              WHEN t.specimen_id IN #{GlobalService.fetch_ids(Specimen, ['CSF', 'Cerebrospinal Fluid'], %w[NLIMS_SP_0002_MWI])} THEN 'Number of CSF cultures done'
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
              t.test_type_id IN #{GlobalService.fetch_ids(TestType, ['Cuture & Sensitivity', 'Culture and Sensitivity'], %w[NLIMS_TT_0004_MWI])}
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
              t.test_type_id IN #{GlobalService.fetch_ids(TestType, ['Cholera', 'Cholera Rapid Diagnostic Test'], %w[NLIMS_TT_0229_MWI])}
              AND ti.id IN #{GlobalService.fetch_ids(TestIndicator, ['Cholera', 'Cholera RDT'], %w[NLIMS_TI_0586_MWI])}
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
              t.test_type_id IN #{GlobalService.fetch_ids(TestType, ['Cholera', 'Cholera Rapid Diagnostic Test'], %w[NLIMS_TT_0229_MWI])}
                AND ti.id IN #{GlobalService.fetch_ids(TestIndicator, ['Cholera', 'Cholera RDT'], %w[NLIMS_TI_0586_MWI])}
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
              t.specimen_id IN #{GlobalService.fetch_ids(Specimen, ['Stool'], %w[NLIMS_SP_0011_MWI])}
              AND ti.id IN #{GlobalService.fetch_ids(TestIndicator, ['Culture'], %w[NLIMS_TI_0784_MWI])}
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
                  ti.id IN #{GlobalService.fetch_ids(TestIndicator, ['Culture'], %w[NLIMS_TI_0784_MWI])}
                  AND o.id IN #{GlobalService.fetch_ids(Organism, ['Cholera'], %w[NLIMS_ORG_0174_MWI NLIMS_ORG_0176_MWI NLIMS_ORG_0178_MWI NLIMS_ORG_0180_MWI])}
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
              t.test_type_id IN #{GlobalService.fetch_ids(TestType, ['Early Infant Diagnosis', 'HIV Early Infant Diagnosis Qualitative HIV Nucleic Acid Test'], %w[NLIMS_TT_0108_MWI])}
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
              t.test_type_id IN #{GlobalService.fetch_ids(TestType, ['Early Infant Diagnosis', 'HIV Early Infant Diagnosis Qualitative HIV Nucleic Acid Test'], %w[NLIMS_TT_0108_MWI])}
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
              test_type_indicator_mappings ttim ON ttim.test_types_id = t.test_type_id
                INNER  JOIN
              test_indicators ti ON ti.id = ttim.test_indicators_id
                INNER JOIN
              test_results tr ON tr.test_indicator_id = ti.id
                AND tr.test_id = t.id
                AND tr.voided = 0
          WHERE
              t.test_type_id IN #{GlobalService.fetch_ids(TestType, ['Early Infant Diagnosis', 'HIV Early Infant Diagnosis Qualitative HIV Nucleic Acid Test'], %w[NLIMS_TT_0108_MWI])}
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
            COUNT(DISTINCT t.id) AS total, 'VL samples received' AS indicator,
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
            t.test_type_id IN #{GlobalService.fetch_ids(TestType, ['Viral Load', 'HIV Viral Load Quantitative HIV Nucleic Acid Test'], %w[NLIMS_TT_0071_MWI])}
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
              test_type_indicator_mappings ttim ON ttim.test_types_id = t.test_type_id
                INNER  JOIN
              test_indicators ti ON ti.id = ttim.test_indicators_id
                INNER JOIN
              test_results tr ON tr.test_indicator_id = ti.id
                AND tr.test_id = t.id
                AND tr.voided = 0
          WHERE
              t.test_type_id IN #{GlobalService.fetch_ids(TestType, ['Viral Load', 'HIV Viral Load Quantitative HIV Nucleic Acid Test'], %w[NLIMS_TT_0071_MWI])}
                AND YEAR(t.created_date) = #{year}
                AND t.status_id IN (4 , 5)
                AND t.voided = 0
                AND tr.value IS NOT NULL
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
            t.test_type_id IN #{GlobalService.fetch_ids(TestType, ['Viral Load', 'HIV Viral Load Quantitative HIV Nucleic Acid Test'], %w[NLIMS_TT_0071_MWI])}
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

      def total_bacteriology_samples_analysed
        test_type_ids = TestType.where(department: Department.find_by(name: 'Microbiology'))
                                .where('nlims_code is not null').pluck(:id)
        specimen_ids = SpecimenTestTypeMapping.where(test_type_id: test_type_ids).pluck(:specimen_id)&.uniq
        specimen_nlims_codes = Specimen.where(id: specimen_ids).pluck(:nlims_code)&.uniq&.compact
        ActiveRecord::Base.connection.execute('SET SESSION group_concat_max_len = 1000000')
        Report.find_by_sql <<~SQL
            SELECT
              MONTHNAME(t.created_date) AS month,
              COUNT(DISTINCT t.order_id) AS total, 'Total Number of bacteriology samples analysed' AS indicator,
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
            t.test_type_id IN #{GlobalService.fetch_ids(TestType, ['Cuture & Sensitivity', 'Culture and Sensitivity'], %w[NLIMS_TT_0004_MWI])}
            AND t.specimen_id IN #{GlobalService.fetch_ids(Specimen, [], specimen_nlims_codes)}
              AND YEAR(t.created_date) = #{year}
              AND t.status_id IN (4 , 5)
              AND t.voided = 0
              AND tr.value NOT IN ('' , '0')
              AND tr.value IS NOT NULL
            GROUP BY MONTHNAME(t.created_date)
        SQL
      end

      # Number of CSF samples analysed
      def csf_samples_analysed
        ActiveRecord::Base.connection.execute('SET SESSION group_concat_max_len = 1000000')
        Report.find_by_sql <<~SQL
            SELECT
              MONTHNAME(t.created_date) AS month,
              COUNT(DISTINCT t.order_id) AS total, 'Total number of CSF samples analysed' AS indicator,
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
            t.specimen_id IN #{GlobalService.fetch_ids(Specimen, ['CSF', 'Cerebrospinal Fluid'], %w[NLIMS_SP_0002_MWI])}
              AND YEAR(t.created_date) = #{year}
              AND t.status_id IN (4 , 5)
              AND t.voided = 0
              AND tr.value NOT IN ('' , '0')
              AND tr.value IS NOT NULL
            GROUP BY MONTHNAME(t.created_date)
        SQL
      end

      # Number of Other Sterile Fluids samples analysed (All sterile fluids except CSF)
      def other_sterile_fluids_analysed
        ActiveRecord::Base.connection.execute('SET SESSION group_concat_max_len = 1000000')
        csf_ids = GlobalService.fetch_ids(Specimen, ['CSF', 'Cerebrospinal Fluid'], %w[NLIMS_SP_0002_MWI])
        Report.find_by_sql <<~SQL
            SELECT
              MONTHNAME(t.created_date) AS month,
              COUNT(DISTINCT t.order_id) AS total, 'Total number of Other Sterile Fluids analysed' AS indicator,
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
              AND t.specimen_id NOT IN #{csf_ids}
              AND YEAR(t.created_date) = #{year}
              AND t.status_id IN (4 , 5)
              AND t.voided = 0
              AND tr.value NOT IN ('' , '0')
              AND tr.value IS NOT NULL
            GROUP BY MONTHNAME(t.created_date)
        SQL
      end

      # Number of Urine samples for culture and sensitivity analysed
      def urine_samples_analysed
        ActiveRecord::Base.connection.execute('SET SESSION group_concat_max_len = 1000000')
        Report.find_by_sql <<~SQL
            SELECT
              MONTHNAME(t.created_date) AS month,
              COUNT(DISTINCT t.order_id) AS total, 'Total number of Urine samples analysed for culture and sensitivity' AS indicator,
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
            t.specimen_id IN #{report_utils.specimen_ids_like('Urine')}
              AND t.test_type_id IN #{GlobalService.fetch_ids(TestType, ['Culture and Sensitivity'], %w[NLIMS_TT_0004_MWI])}
              AND YEAR(t.created_date) = #{year}
              AND t.status_id IN (4 , 5)
              AND t.voided = 0
              AND tr.value NOT IN ('' , '0')
              AND tr.value IS NOT NULL
            GROUP BY MONTHNAME(t.created_date)
        SQL
      end

      # Number of Blood samples for culture and sensitivity analysed
      def blood_samples_analysed
        ActiveRecord::Base.connection.execute('SET SESSION group_concat_max_len = 1000000')
        Report.find_by_sql <<~SQL
            SELECT
              MONTHNAME(t.created_date) AS month,
              COUNT(DISTINCT t.order_id) AS total, 'Total number of Blood samples analysed for culture and sensitivity' AS indicator,
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
            t.specimen_id IN #{report_utils.specimen_ids_like('Blood')}
              AND t.test_type_id IN #{GlobalService.fetch_ids(TestType, ['Culture and Sensitivity'], %w[NLIMS_TT_0004_MWI])}
              AND YEAR(t.created_date) = #{year}
              AND t.status_id IN (4 , 5)
              AND t.voided = 0
              AND tr.value NOT IN ('' , '0')
              AND tr.value IS NOT NULL
            GROUP BY MONTHNAME(t.created_date)
        SQL
      end

      # Number of Pus/Wound swabs for culture and sensitivity analysed
      def pus_wound_swabs_analysed
        ActiveRecord::Base.connection.execute('SET SESSION group_concat_max_len = 1000000')
        Report.find_by_sql <<~SQL
            SELECT
              MONTHNAME(t.created_date) AS month,
              COUNT(DISTINCT t.order_id) AS total, 'Total number of Pus/Wound swabs analysed for culture and sensitivity' AS indicator,
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
            (t.specimen_id IN #{report_utils.specimen_ids_like('Pus')} OR t.specimen_id IN #{report_utils.specimen_ids_like('Wound')} OR t.specimen_id IN #{report_utils.specimen_ids_like('Swab')})
              AND t.test_type_id IN #{GlobalService.fetch_ids(TestType, ['Culture and Sensitivity'], %w[NLIMS_TT_0004_MWI])}
              AND YEAR(t.created_date) = #{year}
              AND t.status_id IN (4 , 5)
              AND t.voided = 0
              AND tr.value NOT IN ('' , '0')
              AND tr.value IS NOT NULL
            GROUP BY MONTHNAME(t.created_date)
        SQL
      end

      # Number of HVS samples for culture and sensitivity analysed
      def hvs_samples_analysed
        ActiveRecord::Base.connection.execute('SET SESSION group_concat_max_len = 1000000')
        Report.find_by_sql <<~SQL
            SELECT
              MONTHNAME(t.created_date) AS month,
              COUNT(DISTINCT t.order_id) AS total, 'Total number of HVS samples analysed for culture and sensitivity' AS indicator,
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
            (t.specimen_id IN #{GlobalService.fetch_ids(Specimen, ['HVS', 'High Vaginal Swab', 'Vaginal Swab'], %w[NLIMS_SP_0014_MWI])} OR t.specimen_id IN #{report_utils.specimen_ids_like('Vaginal')})
              AND t.test_type_id IN #{GlobalService.fetch_ids(TestType, ['Culture and Sensitivity'], %w[NLIMS_TT_0004_MWI])}
              AND YEAR(t.created_date) = #{year}
              AND t.status_id IN (4 , 5)
              AND t.voided = 0
              AND tr.value NOT IN ('' , '0')
              AND tr.value IS NOT NULL
            GROUP BY MONTHNAME(t.created_date)
        SQL
      end

      # Number of Sputum samples for culture and sensitivity analysed
      def sputum_samples_analysed
        ActiveRecord::Base.connection.execute('SET SESSION group_concat_max_len = 1000000')
        Report.find_by_sql <<~SQL
            SELECT
              MONTHNAME(t.created_date) AS month,
              COUNT(DISTINCT t.order_id) AS total, 'Total number of Sputum samples analysed for culture and sensitivity' AS indicator,
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
            t.specimen_id IN #{report_utils.specimen_ids_like('Sputum')}
              AND t.test_type_id IN #{GlobalService.fetch_ids(TestType, ['Culture and Sensitivity'], %w[NLIMS_TT_0004_MWI])}
              AND YEAR(t.created_date) = #{year}
              AND t.status_id IN (4 , 5)
              AND t.voided = 0
              AND tr.value NOT IN ('' , '0')
              AND tr.value IS NOT NULL
            GROUP BY MONTHNAME(t.created_date)
        SQL
      end

      # Number of Stool samples for culture and sensitivity analysed
      def stool_samples_analysed
        ActiveRecord::Base.connection.execute('SET SESSION group_concat_max_len = 1000000')
        Report.find_by_sql <<~SQL
            SELECT
              MONTHNAME(t.created_date) AS month,
              COUNT(DISTINCT t.order_id) AS total, 'Total number of Stool samples analysed for culture and sensitivity' AS indicator,
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
            t.specimen_id IN #{report_utils.specimen_ids_like('Stool')}
              AND t.test_type_id IN #{GlobalService.fetch_ids(TestType, ['Culture and Sensitivity'], %w[NLIMS_TT_0004_MWI])}
              AND YEAR(t.created_date) = #{year}
              AND t.status_id IN (4 , 5)
              AND t.voided = 0
              AND tr.value NOT IN ('' , '0')
              AND tr.value IS NOT NULL
            GROUP BY MONTHNAME(t.created_date)
        SQL
      end

      # Number of Other samples analysed (samples not in the above categories, e.g., tissue biopsy)
      def other_samples_analysed
        ActiveRecord::Base.connection.execute('SET SESSION group_concat_max_len = 1000000')
        csf_ids = GlobalService.fetch_ids(Specimen, ['CSF', 'Cerebrospinal Fluid'], %w[NLIMS_SP_0002_MWI])
        hvs_ids = GlobalService.fetch_ids(Specimen, ['HVS', 'High Vaginal Swab', 'Vaginal Swab'], %w[NLIMS_SP_0014_MWI])
        Report.find_by_sql <<~SQL
            SELECT
              MONTHNAME(t.created_date) AS month,
              COUNT(DISTINCT t.order_id) AS total, 'Total number of Other samples analysed' AS indicator,
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
            t.specimen_id NOT IN #{csf_ids}
              AND t.specimen_id NOT IN #{hvs_ids}
              AND t.specimen_id NOT IN #{report_utils.specimen_ids_like('Fluid')}
              AND t.specimen_id NOT IN #{report_utils.specimen_ids_like('Urine')}
              AND t.specimen_id NOT IN #{report_utils.specimen_ids_like('Blood')}
              AND t.specimen_id NOT IN #{report_utils.specimen_ids_like('Pus')}
              AND t.specimen_id NOT IN #{report_utils.specimen_ids_like('Wound')}
              AND t.specimen_id NOT IN #{report_utils.specimen_ids_like('Swab')}
              AND t.specimen_id NOT IN #{report_utils.specimen_ids_like('Sputum')}
              AND t.specimen_id NOT IN #{report_utils.specimen_ids_like('Stool')}
              AND t.specimen_id NOT IN #{report_utils.specimen_ids_like('Vaginal')}
              AND t.test_type_id IN #{GlobalService.fetch_ids(TestType, ['Culture and Sensitivity'], %w[NLIMS_TT_0004_MWI])}
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
            t.specimen_id IN #{GlobalService.fetch_ids(Specimen, ['CSF', 'Cerebrospinal Fluid'], %w[NLIMS_SP_0002_MWI])}
              AND t.test_type_id IN #{GlobalService.fetch_ids(TestType, ['TB Tests'], %w[NLIMS_TT_0010_MWI])}
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
            t.specimen_id IN #{GlobalService.fetch_ids(Specimen, ['CSF', 'Cerebrospinal Fluid'], %w[NLIMS_SP_0002_MWI])}
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
            t.test_type_id IN #{GlobalService.fetch_ids(TestType, ['India Ink'], %w[NLIMS_TT_0006_MWI])}
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
            t.test_type_id IN #{GlobalService.fetch_ids(TestType, ['India Ink'], %w[NLIMS_TT_0006_MWI])}
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
            t.test_type_id IN #{GlobalService.fetch_ids(TestType, ['Gram Stain'], %w[NLIMS_TT_0003_MWI])}
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
            t.test_type_id IN #{GlobalService.fetch_ids(TestType, ['Gram Stain'], %w[NLIMS_TT_0003_MWI])}
              AND YEAR(t.created_date) = #{year}
              AND t.status_id IN (4 , 5)
              AND t.voided = 0
              AND tr.value IS NOT NULL
              AND tr.value LIKE '%Positive%'
              AND tr.value NOT IN ('', '0')
            GROUP BY MONTHNAME(t.created_date)
        SQL
      end

      def gram_stain_by_specimen
        ActiveRecord::Base.connection.execute('SET SESSION group_concat_max_len = 1000000')
        Report.find_by_sql <<~SQL
          SELECT
            CASE
                WHEN t.specimen_id IN #{csf} THEN 'Gram Stain CSF'
                WHEN t.specimen_id IN #{non_csf_fluids} THEN 'Gram Stain Other Sterile Fluids'
                WHEN t.specimen_id IN #{blood} THEN 'Gram Stain Blood'
                WHEN t.specimen_id IN #{pus} THEN 'Gram Stain Pus/Wound swabs'
                WHEN t.specimen_id IN #{hvs} THEN 'Gram Stain High Vaginal swabs (HVS)'
                WHEN t.specimen_id IN #{sputum} THEN 'Gram Stain Sputum'
                ELSE 'Gram Stain Other Samples'
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
            t.test_type_id IN #{GlobalService.fetch_ids(TestType, ['Gram Stain'], %w[NLIMS_TT_0003_MWI])}
              AND YEAR(t.created_date) = #{year}
              AND t.status_id IN (4, 5)
              AND t.voided = 0
              AND tr.value IS NOT NULL
              AND tr.value NOT IN ('', '0')
          GROUP BY MONTHNAME(t.created_date), indicator
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
            t.specimen_id IN #{GlobalService.fetch_ids(Specimen, ['HVS'], ['NLIMS_SP_0008_MWI'])}
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
            t.specimen_id IN #{GlobalService.fetch_ids(Specimen, ['HVS'], ['NLIMS_SP_0008_MWI'])}
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
            t.test_type_id IN #{GlobalService.fetch_ids(TestType, ['Cryptococcus Antigen Test'], %w[NLIMS_TT_0023_MWI])}
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
            t.test_type_id IN #{GlobalService.fetch_ids(TestType, ['Cryptococcus Antigen Test'], %w[NLIMS_TT_0023_MWI])}
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
            t.test_type_id IN #{GlobalService.fetch_ids(TestType, ['Serum CrAg', 'Cryptococcus Antigen', 'Cryptococcus Antigen Test'], %w[NLIMS_TT_0023_MWI])}
              AND t.specimen_id IN #{GlobalService.fetch_ids(Specimen, ['Blood', 'Venous Whole Blood', 'Serum'], %w[NLIMS_SP_0020_MWI NLIMS_SP_0003_MWI])}
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
            t.test_type_id IN #{GlobalService.fetch_ids(TestType, ['Serum CrAg', 'Cryptococcus Antigen', 'Cryptococcus Antigen Test'], %w[NLIMS_TT_0023_MWI])}
              AND t.specimen_id IN #{GlobalService.fetch_ids(Specimen, ['Blood', 'Venous Whole Blood', 'Serum'], %w[NLIMS_SP_0020_MWI NLIMS_SP_0003_MWI])}
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
            t.specimen_id IN #{report_utils.specimen_ids_like('Swab')}
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
            t.specimen_id IN #{report_utils.specimen_ids_like('Swab')}
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

      def total_cultures_done
        ActiveRecord::Base.connection.execute('SET SESSION group_concat_max_len = 1000000')
        Report.find_by_sql <<~SQL
          SELECT
            MONTHNAME(t.created_date) AS month,
            COUNT(DISTINCT t.order_id) AS total, 'Total number of Cultures done' AS indicator,
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
            t.test_type_id IN #{GlobalService.fetch_ids(TestType, ['Culture and Sensitivity'], %w[NLIMS_TT_0004_MWI])}
              AND YEAR(t.created_date) = #{year}
              AND t.status_id IN (4 , 5)
              AND t.voided = 0
              AND tr.value IS NOT NULL
              AND tr.value NOT IN ('', '0')
          GROUP BY MONTHNAME(t.created_date)
        SQL
      end

      def total_cultures_with_growth
        ActiveRecord::Base.connection.execute('SET SESSION group_concat_max_len = 1000000')
        Report.find_by_sql <<~SQL
          SELECT
            MONTHNAME(t.created_date) AS month,
            COUNT(DISTINCT t.order_id) AS total, 'Total number of Cultures with growth' AS indicator,
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
            t.test_type_id IN #{GlobalService.fetch_ids(TestType, ['Culture and Sensitivity'], %w[NLIMS_TT_0004_MWI])}
              AND YEAR(t.created_date) = #{year}
              AND t.status_id IN (4 , 5)
              AND t.voided = 0
              AND tr.value IS NOT NULL
              AND tr.value NOT IN ('', '0')
              AND tr.value IN ('growth', 'Growth')
          GROUP BY MONTHNAME(t.created_date)
        SQL
      end

      def total_cultures_with_na_result_value
        ActiveRecord::Base.connection.execute('SET SESSION group_concat_max_len = 1000000')
        Report.find_by_sql <<~SQL
          SELECT
            MONTHNAME(t.created_date) AS month,
            COUNT(DISTINCT t.order_id) AS total, 'Total number of Cultures with other growth results values' AS indicator,
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
            t.test_type_id IN #{GlobalService.fetch_ids(TestType, ['Culture and Sensitivity'], %w[NLIMS_TT_0004_MWI])}
              AND YEAR(t.created_date) = #{year}
              AND t.status_id IN (4 , 5)
              AND t.voided = 0
              AND tr.value IS NOT NULL
              AND tr.value NOT IN ('', '0')
              AND tr.value NOT IN ("Growth", "No Growth", "Growth of Yeast Cells",
                "Growth of normal flora; no pathogens isolated", "Growth of contaminants", "Mixed growth; no predominant organism")
          GROUP BY MONTHNAME(t.created_date)
        SQL
      end

      def total_cultures_with_no_growth
        ActiveRecord::Base.connection.execute('SET SESSION group_concat_max_len = 1000000')
        Report.find_by_sql <<~SQL
          SELECT
            MONTHNAME(t.created_date) AS month,
            COUNT(DISTINCT t.order_id) AS total, 'Total number of Cultures with no growth' AS indicator,
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
            t.test_type_id IN #{GlobalService.fetch_ids(TestType, ['Culture and Sensitivity'], %w[NLIMS_TT_0004_MWI])}
              AND YEAR(t.created_date) = #{year}
              AND t.status_id IN (4 , 5)
              AND t.voided = 0
              AND tr.value IS NOT NULL
              AND tr.value NOT IN ('', '0')
              AND tr.value IN ('No growth', 'no growth')
          GROUP BY MONTHNAME(t.created_date)
        SQL
      end

      def total_cultures_with_mixed_growth
        ActiveRecord::Base.connection.execute('SET SESSION group_concat_max_len = 1000000')
        Report.find_by_sql <<~SQL
          SELECT
            MONTHNAME(t.created_date) AS month,
            COUNT(DISTINCT t.order_id) AS total, 'Total number of Cultures with mixed growth (no predominant organism)' AS indicator,
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
            t.test_type_id IN #{GlobalService.fetch_ids(TestType, ['Culture and Sensitivity'], %w[NLIMS_TT_0004_MWI])}
              AND YEAR(t.created_date) = #{year}
              AND t.status_id IN (4 , 5)
              AND t.voided = 0
              AND tr.value IS NOT NULL
              AND tr.value NOT IN ('', '0')
              AND tr.value IN ('Mixed growth; no predominant organism')
          GROUP BY MONTHNAME(t.created_date)
        SQL
      end

      def total_cultures_with_growth_of_normal_flora
        ActiveRecord::Base.connection.execute('SET SESSION group_concat_max_len = 1000000')
        Report.find_by_sql <<~SQL
          SELECT
            MONTHNAME(t.created_date) AS month,
            COUNT(DISTINCT t.order_id) AS total, 'Total number of Cultures with growth of normal flora' AS indicator,
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
            t.test_type_id IN #{GlobalService.fetch_ids(TestType, ['Culture and Sensitivity'], %w[NLIMS_TT_0004_MWI])}
              AND YEAR(t.created_date) = #{year}
              AND t.status_id IN (4 , 5)
              AND t.voided = 0
              AND tr.value IS NOT NULL
              AND tr.value NOT IN ('', '0')
              AND tr.value IN ('Growth of normal flora; no pathogens isolated')
          GROUP BY MONTHNAME(t.created_date)
        SQL
      end

      def total_cultures_with_growth_of_contaminants
        ActiveRecord::Base.connection.execute('SET SESSION group_concat_max_len = 1000000')
        Report.find_by_sql <<~SQL
          SELECT
            MONTHNAME(t.created_date) AS month,
            COUNT(DISTINCT t.order_id) AS total, 'Total number of Cultures with growth of contaminants' AS indicator,
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
            t.test_type_id IN #{GlobalService.fetch_ids(TestType, ['Culture and Sensitivity'], %w[NLIMS_TT_0004_MWI])}
              AND YEAR(t.created_date) = #{year}
              AND t.status_id IN (4 , 5)
              AND t.voided = 0
              AND tr.value IS NOT NULL
              AND tr.value NOT IN ('', '0')
              AND tr.value IN ('Growth of contaminants')
          GROUP BY MONTHNAME(t.created_date)
        SQL
      end

      def total_cultures_with_growth_of_yeast_cells
        ActiveRecord::Base.connection.execute('SET SESSION group_concat_max_len = 1000000')
        Report.find_by_sql <<~SQL
          SELECT
            MONTHNAME(t.created_date) AS month,
            COUNT(DISTINCT t.order_id) AS total, 'Total number of Cultures with growth of Yeast Cells' AS indicator,
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
            t.test_type_id IN #{GlobalService.fetch_ids(TestType, ['Culture and Sensitivity'], %w[NLIMS_TT_0004_MWI])}
              AND YEAR(t.created_date) = #{year}
              AND t.status_id IN (4 , 5)
              AND t.voided = 0
              AND tr.value IS NOT NULL
              AND tr.value NOT IN ('', '0')
              AND tr.value IN ('Growth of Yeast Cells')
          GROUP BY MONTHNAME(t.created_date)
        SQL
      end

      def total_ast_done
        ActiveRecord::Base.connection.execute('SET SESSION group_concat_max_len = 1000000')
        Report.find_by_sql <<~SQL
          SELECT
            MONTHNAME(t.created_date) AS month,
            COUNT(DISTINCT t.order_id) AS total, 'Total number of AST done' AS indicator,
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
              INNER JOIN
            drug_susceptibilities ds ON ds.test_id = t.id AND ds.voided = 0
          WHERE
            t.test_type_id IN #{GlobalService.fetch_ids(TestType, ['Culture and Sensitivity'], %w[NLIMS_TT_0004_MWI])}
              AND YEAR(t.created_date) = #{year}
              AND t.status_id IN (4 , 5)
              AND t.voided = 0
              AND tr.value IS NOT NULL
              AND tr.value NOT IN ('', '0')
              AND tr.value IN ('Growth', 'growth')
              AND ds.zone IS NOT NULL
              AND ds.zone NOT IN ('', '0')
              AND ds.interpretation IS NOT NULL
              AND ds.interpretation NOT IN ('', '0')
          GROUP BY MONTHNAME(t.created_date)
        SQL
      end

      def csf_ast_organisms
        ActiveRecord::Base.connection.execute('SET SESSION group_concat_max_len = 1000000')
        Report.find_by_sql <<~SQL
          SELECT
            CASE
                WHEN ds.organism_id IN #{e_coli} AND t.specimen_id IN #{csf} THEN 'E.Coli Isolated from CSF'
                WHEN ds.organism_id IN #{e_coli} AND t.specimen_id IN #{non_csf_fluids} THEN 'E.Coli Isolated from other sterile fluids except CSF'
                WHEN ds.organism_id IN #{e_coli} AND t.specimen_id IN #{urine} THEN 'E.Coli Isolated from Urine'
                WHEN ds.organism_id IN #{e_coli} AND t.specimen_id IN #{blood} THEN 'E.Coli Isolated from Blood'
                WHEN ds.organism_id IN #{e_coli} AND t.specimen_id IN #{pus} THEN 'E.Coli Isolated from Pus'
                WHEN ds.organism_id IN #{e_coli} AND t.specimen_id IN #{hvs} THEN 'E.Coli Isolated from HVS'
                WHEN ds.organism_id IN #{e_coli} AND t.specimen_id IN #{stool} THEN 'E.Coli Isolated from Stool'
                WHEN ds.organism_id IN #{e_coli} AND t.specimen_id IN #{other_samples} THEN 'E.Coli Isolated from Other Samples'

                WHEN ds.organism_id IN #{klebsiella_spp} AND t.specimen_id IN #{csf} THEN 'Klebsiella Spp Isolated from CSF'
                WHEN ds.organism_id IN #{klebsiella_spp} AND t.specimen_id IN #{non_csf_fluids} THEN 'Klebsiella Spp Isolated from other sterile fluids except CSF'
                WHEN ds.organism_id IN #{klebsiella_spp} AND t.specimen_id IN #{urine} THEN 'Klebsiella Spp Isolated from Urine'
                WHEN ds.organism_id IN #{klebsiella_spp} AND t.specimen_id IN #{blood} THEN 'Klebsiella Spp Isolated from Blood'
                WHEN ds.organism_id IN #{klebsiella_spp} AND t.specimen_id IN #{pus} THEN 'Klebsiella Spp Isolated from Pus'
                WHEN ds.organism_id IN #{klebsiella_spp} AND t.specimen_id IN #{hvs} THEN 'Klebsiella Spp Isolated from HVS'
                WHEN ds.organism_id IN #{klebsiella_spp} AND t.specimen_id IN #{other_samples} THEN 'Klebsiella Spp Isolated from Other Samples'

                WHEN ds.organism_id IN #{acinetobacter_spp} AND t.specimen_id IN #{csf} THEN 'Acinetobacter Spp Isolated from CSF'
                WHEN ds.organism_id IN #{acinetobacter_spp} AND t.specimen_id IN #{non_csf_fluids} THEN 'Acinetobacter Spp Isolated from other sterile fluids except CSF'
                WHEN ds.organism_id IN #{acinetobacter_spp} AND t.specimen_id IN #{urine} THEN 'Acinetobacter Spp Isolated from Urine'
                WHEN ds.organism_id IN #{acinetobacter_spp} AND t.specimen_id IN #{blood} THEN 'Acinetobacter Spp Isolated from Blood'
                WHEN ds.organism_id IN #{acinetobacter_spp} AND t.specimen_id IN #{pus} THEN 'Acinetobacter Spp Isolated from Pus'
                WHEN ds.organism_id IN #{acinetobacter_spp} AND t.specimen_id IN #{hvs} THEN 'Acinetobacter Spp Isolated from HVS'
                WHEN ds.organism_id IN #{acinetobacter_spp} AND t.specimen_id IN #{stool} THEN 'Acinetobacter Spp Isolated from Stool'
                WHEN ds.organism_id IN #{acinetobacter_spp} AND t.specimen_id IN #{other_samples} THEN 'Acinetobacter Spp Isolated from Other Samples'

                WHEN ds.organism_id IN #{proteus_spp} AND t.specimen_id IN #{csf} THEN 'Proteus Spp Isolated from CSF'
                WHEN ds.organism_id IN #{proteus_spp} AND t.specimen_id IN #{non_csf_fluids} THEN 'Proteus Spp Isolated from other sterile fluids except CSF'
                WHEN ds.organism_id IN #{proteus_spp} AND t.specimen_id IN #{urine} THEN 'Proteus Spp Isolated from Urine'
                WHEN ds.organism_id IN #{proteus_spp} AND t.specimen_id IN #{blood} THEN 'Proteus Spp Isolated from Blood'
                WHEN ds.organism_id IN #{proteus_spp} AND t.specimen_id IN #{pus} THEN 'Proteus Spp Isolated from Pus'
                WHEN ds.organism_id IN #{proteus_spp} AND t.specimen_id IN #{hvs} THEN 'Proteus Spp Isolated from HVS'
                WHEN ds.organism_id IN #{proteus_spp} AND t.specimen_id IN #{other_samples} THEN 'Proteus Spp Isolated from Other Samples'

                WHEN ds.organism_id IN #{salmonella_spp} AND t.specimen_id IN #{csf} THEN 'Salmonella Spp Isolated from CSF'
                WHEN ds.organism_id IN #{salmonella_spp} AND t.specimen_id IN #{non_csf_fluids} THEN 'Salmonella Spp Isolated from other sterile fluids except CSF'
                WHEN ds.organism_id IN #{salmonella_spp} AND t.specimen_id IN #{urine} THEN 'Salmonella Spp Isolated from Urine'
                WHEN ds.organism_id IN #{salmonella_spp} AND t.specimen_id IN #{blood} THEN 'Salmonella Spp Isolated from Blood'
                WHEN ds.organism_id IN #{salmonella_spp} AND t.specimen_id IN #{pus} THEN 'Salmonella Spp Isolated from Pus'
                WHEN ds.organism_id IN #{salmonella_spp} AND t.specimen_id IN #{hvs} THEN 'Salmonella Spp Isolated from HVS'
                WHEN ds.organism_id IN #{salmonella_spp} AND t.specimen_id IN #{stool} THEN 'Salmonella Spp Isolated from Stool'
                WHEN ds.organism_id IN #{salmonella_spp} AND t.specimen_id IN #{other_samples} THEN 'Salmonella Spp Isolated from Other Samples'

                WHEN ds.organism_id IN #{pseudomonas_spp} AND t.specimen_id IN #{csf} THEN 'Pseudomonas Spp Isolated from CSF'
                WHEN ds.organism_id IN #{pseudomonas_spp} AND t.specimen_id IN #{non_csf_fluids} THEN 'Pseudomonas Spp Isolated from other sterile fluids except CSF'
                WHEN ds.organism_id IN #{pseudomonas_spp} AND t.specimen_id IN #{urine} THEN 'Pseudomonas Spp Isolated from Urine'
                WHEN ds.organism_id IN #{pseudomonas_spp} AND t.specimen_id IN #{blood} THEN 'Pseudomonas Spp Isolated from Blood'
                WHEN ds.organism_id IN #{pseudomonas_spp} AND t.specimen_id IN #{pus} THEN 'Pseudomonas Spp Isolated from Pus'
                WHEN ds.organism_id IN #{pseudomonas_spp} AND t.specimen_id IN #{hvs} THEN 'Pseudomonas Spp Isolated from HVS'
                WHEN ds.organism_id IN #{pseudomonas_spp} AND t.specimen_id IN #{stool} THEN 'Pseudomonas Spp Isolated from Stool'
                WHEN ds.organism_id IN #{pseudomonas_spp} AND t.specimen_id IN #{other_samples} THEN 'Pseudomonas Spp Isolated from Other Samples'

                WHEN ds.organism_id IN #{strept_pneumoniae} AND t.specimen_id IN #{csf} THEN 'Strept pneumoniae Isolated from CSF'
                WHEN ds.organism_id IN #{strept_pneumoniae} AND t.specimen_id IN #{non_csf_fluids} THEN 'Strept pneumoniae Isolated from other sterile fluids except CSF'
                WHEN ds.organism_id IN #{strept_pneumoniae} AND t.specimen_id IN #{urine} THEN 'Strept pneumoniae Isolated from Urine'
                WHEN ds.organism_id IN #{strept_pneumoniae} AND t.specimen_id IN #{blood} THEN 'Strept pneumoniae Isolated from Blood'
                WHEN ds.organism_id IN #{strept_pneumoniae} AND t.specimen_id IN #{pus} THEN 'Strept pneumoniae Isolated from Pus'
                WHEN ds.organism_id IN #{strept_pneumoniae} AND t.specimen_id IN #{hvs} THEN 'Strept pneumoniae Isolated from HVS'
                WHEN ds.organism_id IN #{strept_pneumoniae} AND t.specimen_id IN #{other_samples} THEN 'Strept pneumoniae Isolated from Other Samples'

                WHEN ds.organism_id IN #{strept_a_b} AND t.specimen_id IN #{csf} THEN 'Strep spp (A,B) Isolated from CSF'
                WHEN ds.organism_id IN #{strept_a_b} AND t.specimen_id IN #{non_csf_fluids} THEN 'Strep spp (A,B) Isolated from other sterile fluids except CSF'
                WHEN ds.organism_id IN #{strept_a_b} AND t.specimen_id IN #{urine} THEN 'Strep spp (A,B) Isolated from Urine'
                WHEN ds.organism_id IN #{strept_a_b} AND t.specimen_id IN #{blood} THEN 'Strep spp (A,B) Isolated from Blood'
                WHEN ds.organism_id IN #{strept_a_b} AND t.specimen_id IN #{pus} THEN 'Strep spp (A,B) Isolated from Pus'
                WHEN ds.organism_id IN #{strept_a_b} AND t.specimen_id IN #{hvs} THEN 'Strep spp (A,B) Isolated from HVS'
                WHEN ds.organism_id IN #{strept_a_b} AND t.specimen_id IN #{stool} THEN 'Strep spp (A,B) Isolated from Stool'
                WHEN ds.organism_id IN #{strept_a_b} AND t.specimen_id IN #{other_samples} THEN 'Strep spp (A,B) Isolated from Other Samples'

                WHEN ds.organism_id IN #{enterococcus_spp} AND t.specimen_id IN #{csf} THEN 'Enterococcus spp Isolated from CSF'
                WHEN ds.organism_id IN #{enterococcus_spp} AND t.specimen_id IN #{non_csf_fluids} THEN 'Enterococcus spp Isolated from other sterile fluids except CSF'
                WHEN ds.organism_id IN #{enterococcus_spp} AND t.specimen_id IN #{urine} THEN 'Enterococcus spp Isolated from Urine'
                WHEN ds.organism_id IN #{enterococcus_spp} AND t.specimen_id IN #{blood} THEN 'Enterococcus spp Isolated from Blood'
                WHEN ds.organism_id IN #{enterococcus_spp} AND t.specimen_id IN #{pus} THEN 'Enterococcus spp Isolated from Pus'
                WHEN ds.organism_id IN #{enterococcus_spp} AND t.specimen_id IN #{hvs} THEN 'Enterococcus spp Isolated from HVS'
                WHEN ds.organism_id IN #{enterococcus_spp} AND t.specimen_id IN #{other_samples} THEN 'Enterococcus spp Isolated from Other Samples'

                WHEN ds.organism_id IN #{staphylococcus_aureus} AND t.specimen_id IN #{csf} THEN 'Staphylcoccus Aureus Isolated from CSF'
                WHEN ds.organism_id IN #{staphylococcus_aureus} AND t.specimen_id IN #{non_csf_fluids} THEN 'Staphylcoccus Aureus Isolated from other sterile fluids except CSF'
                WHEN ds.organism_id IN #{staphylococcus_aureus} AND t.specimen_id IN #{urine} THEN 'Staphylcoccus Aureus Isolated from Urine'
                WHEN ds.organism_id IN #{staphylococcus_aureus} AND t.specimen_id IN #{blood} THEN 'Staphylcoccus Aureus Isolated from Blood'
                WHEN ds.organism_id IN #{staphylococcus_aureus} AND t.specimen_id IN #{pus} THEN 'Staphylcoccus Aureus Isolated from Pus'
                WHEN ds.organism_id IN #{staphylococcus_aureus} AND t.specimen_id IN #{hvs} THEN 'Staphylcoccus Aureus Isolated from HVS'
                WHEN ds.organism_id IN #{staphylococcus_aureus} AND t.specimen_id IN #{other_samples} THEN 'Staphylcoccus Aureus Isolated from Other Samples'

                WHEN ds.organism_id IN #{neisseria_spp} AND t.specimen_id IN #{csf} THEN 'Neisseria spp Isolated from CSF'
                WHEN ds.organism_id IN #{neisseria_spp} AND t.specimen_id IN #{non_csf_fluids} THEN 'Neisseria spp Isolated from other sterile fluids except CSF'
                WHEN ds.organism_id IN #{neisseria_spp} AND t.specimen_id IN #{urine} THEN 'Neisseria spp Isolated from Urine'
                WHEN ds.organism_id IN #{neisseria_spp} AND t.specimen_id IN #{blood} THEN 'Neisseria spp Isolated from Blood'
                WHEN ds.organism_id IN #{neisseria_spp} AND t.specimen_id IN #{pus} THEN 'Neisseria spp Isolated from Pus'
                WHEN ds.organism_id IN #{neisseria_spp} AND t.specimen_id IN #{hvs} THEN 'Neisseria spp Isolated from HVS'
                WHEN ds.organism_id IN #{neisseria_spp} AND t.specimen_id IN #{other_samples} THEN 'Neisseria spp Isolated from Other Samples'

                WHEN ds.organism_id IN #{cryptococcus_spp} AND t.specimen_id IN #{csf} THEN 'Cryptococcal Spp Isolated from CSF'
                WHEN ds.organism_id IN #{cryptococcus_spp} AND t.specimen_id IN #{non_csf_fluids} THEN 'Cryptococcal Spp Isolated from other sterile fluids except CSF'

                WHEN ds.organism_id IN #{shigella_spp} AND t.specimen_id IN #{blood} THEN 'Shigella Spp Isolated from Blood'
                WHEN ds.organism_id IN #{shigella_spp} AND t.specimen_id IN #{stool} THEN 'Shigella Spp Isolated from Stool'
                WHEN ds.organism_id IN #{shigella_spp} AND t.specimen_id IN #{other_samples} THEN 'Shigella Spp Isolated from Other Samples'

                WHEN ds.organism_id IN #{other_spp} AND t.specimen_id IN #{csf} THEN 'Other Spp Isolated from CSF'
                WHEN ds.organism_id IN #{other_spp} AND t.specimen_id IN #{non_csf_fluids} THEN 'Other Spp Isolated from other sterile fluids except CSF'
                WHEN ds.organism_id IN #{other_spp} AND t.specimen_id IN #{urine} THEN 'Other Spp Isolated from Urine'
                WHEN ds.organism_id IN #{other_spp} AND t.specimen_id IN #{blood} THEN 'Other Spp Isolated from Blood'
                WHEN ds.organism_id IN #{other_spp} AND t.specimen_id IN #{pus} THEN 'Other Spp Isolated from Pus'
                WHEN ds.organism_id IN #{other_spp} AND t.specimen_id IN #{hvs} THEN 'Other Spp Isolated from HVS'
                WHEN ds.organism_id IN #{other_spp} AND t.specimen_id IN #{stool} THEN 'Other Spp Isolated from Stool'
                WHEN ds.organism_id IN #{other_spp} AND t.specimen_id IN #{other_samples} THEN 'Other Spp Isolated from Other Samples'

                ELSE 'N/A'
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
              INNER JOIN
            drug_susceptibilities ds ON ds.test_id = t.id AND ds.voided = 0
          WHERE
            t.test_type_id IN #{GlobalService.fetch_ids(TestType, ['Culture and Sensitivity'], %w[NLIMS_TT_0004_MWI])}
              AND YEAR(t.created_date) = #{year}
              AND t.status_id IN (4 , 5)
              AND t.voided = 0
              AND tr.value IS NOT NULL
              AND tr.value NOT IN ('', '0')
              AND tr.value IN ('Growth', 'growth')
              AND ds.zone IS NOT NULL
              AND ds.zone NOT IN ('', '0')
              AND ds.interpretation IS NOT NULL
              AND ds.interpretation NOT IN ('', '0')
          GROUP BY MONTHNAME(t.created_date), indicator
        SQL
      end

      def tb_tests_done
        ActiveRecord::Base.connection.execute('SET SESSION group_concat_max_len = 1000000')
        Report.find_by_sql <<~SQL
          SELECT
            CASE
                WHEN t.specimen_id IN #{csf} THEN 'TB Tests done on CSF'
                WHEN t.specimen_id IN #{non_csf_fluids} THEN 'TB Tests done on other sterile fluids except CSF'
                WHEN t.specimen_id IN #{urine} THEN 'TB Tests done on Urine'
                WHEN t.specimen_id IN #{pus} THEN 'TB Tests done on Pus'
                WHEN t.specimen_id IN #{stool} THEN 'TB Tests done on Stool'
                WHEN t.specimen_id IN #{sputum} THEN 'TB Tests done on Sputum'
                WHEN t.specimen_id IN #{other_tb_samples} THEN 'TB Tests done on Other TB Samples'
                ELSE 'N/A'
            END AS indicator,
            MONTHNAME(t.created_date) AS month,
            COUNT(DISTINCT t.order_id) AS total,
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
            t.test_type_id IN #{GlobalService.fetch_ids(TestType, ['TB Tests'], %w[NLIMS_TT_0010_MWI])}
              AND YEAR(t.created_date) = #{year}
              AND t.status_id IN (4 , 5)
              AND t.voided = 0
              AND tr.value IS NOT NULL
              AND tr.value NOT IN ('', '0')
          GROUP BY MONTHNAME(t.created_date), indicator
        SQL
      end

      def non_csf_fluids
        GlobalService.fetch_ids(Specimen, ['Ascitic Fluid', 'Fluid Aspirate', 'Oral Fluid', 'Pericardial Fluid', 'Peritoneal Fluid', 'Pleural Fluid', 'Synovial Fluid'],
                                %w[NLIMS_SP_0005_MWI NLIMS_SP_0025_MWI NLIMS_SP_0047_MWI NLIMS_SP_0006_MWI NLIMS_SP_0007_MWI NLIMS_SP_0004_MWI NLIMS_SP_0016_MWI])
      end

      def csf
        GlobalService.fetch_ids(Specimen, ['CSF', 'Cerebrospinal Fluid'], %w[NLIMS_SP_0002_MWI])
      end

      def urine
        GlobalService.fetch_ids(Specimen, ['Urine'], %w[NLIMS_SP_0012_MWI])
      end

      def blood
        GlobalService.fetch_ids(Specimen, ['Blood', 'Venous Whole Blood'], %w[NLIMS_SP_0003_MWI])
      end

      def pus
        GlobalService.fetch_ids(Specimen, ['Pus'], %w[NLIMS_SP_0010_MWI])
      end

      def hvs
        GlobalService.fetch_ids(Specimen, ['HVS'], %w[NLIMS_SP_0008_MWI])
      end

      def stool
        GlobalService.fetch_ids(Specimen, ['Stool'], %w[NLIMS_SP_0011_MWI])
      end

      def sputum
        GlobalService.fetch_ids(Specimen, ['Sputum'], %w[NLIMS_SP_0001_MWI])
      end

      def other_tb_samples
        other_sp = csf + non_csf_fluids + urine + blood + pus + hvs + stool + sputum
        other_sp_ids = other_sp.gsub(/[()]/, '').split(',').map { |n| n.strip.to_i }
        other_specimens = Specimen.where.not(id: other_sp_ids)
        GlobalService.fetch_ids(Specimen, other_specimens.pluck(:name), other_specimens.pluck(:nlims_code))
      end

      def other_samples
        other_sp = csf + non_csf_fluids + urine + blood + pus + hvs + stool
        other_sp_ids = other_sp.gsub(/[()]/, '').split(',').map { |n| n.strip.to_i }
        other_specimens = Specimen.where.not(id: other_sp_ids)
        GlobalService.fetch_ids(Specimen, other_specimens.pluck(:name), other_specimens.pluck(:nlims_code))
      end

      def e_coli
        GlobalService.fetch_ids(Organism, ['Escherichia coli', 'E.coli'], %w[NLIMS_ORG_0033_MWI])
      end

      def klebsiella_spp
        GlobalService.fetch_ids(Organism, ['Klebsiella oxytoca', 'Klebsiella ozaenae', 'Klebsiella pneumoniae', 'Klebsiella species'],
                                %w[NLIMS_ORG_0084_MWI NLIMS_ORG_0086_MWI NLIMS_ORG_0087_MWI NLIMS_ORG_0089_MWI])
      end

      def acinetobacter_spp
        GlobalService.fetch_ids(Organism, ['Acinetobacter baumanni / haemolyticus', 'Acinetobacter lwoffii', 'Acinetobacter species', 'Acinetobacter baumannii / haemolytlcus'],
                                %w[NLIMS_ORG_0019_MWI NLIMS_ORG_0020_MWI NLIMS_ORG_0021_MWI NLIMS_ORG_0031_MWI])
      end

      def proteus_spp
        GlobalService.fetch_ids(Organism, ['Proteus mirabilis', '	Proteus species', 'Proteus vulgaris'],
                                %w[NLIMS_ORG_0162_MWI NLIMS_ORG_0164_MWI NLIMS_ORG_0166_MWI])
      end

      def salmonella_spp
        GlobalService.fetch_ids(Organism, ['Salmonellae', 'Salmonella Arizonae', 'Salmonella Enteritidis', 'Salmonella Gallinarum', 'Salmonella paratyphi A', 'Salmonella paratyphi B', 'Salmonella paratyphi C',
                                           'Salmonella pullorum', 'Salmonella species', 'Salmonella Typhi', 'Salmonella Typhimurium'],
                                %w[NLIMS_ORG_0010_MWI NLIMS_ORG_0188_MWI NLIMS_ORG_0190_MWI NLIMS_ORG_0192_MWI NLIMS_ORG_0196_MWI NLIMS_ORG_0199_MWI NLIMS_ORG_0201_MWI NLIMS_ORG_0203_MWI NLIMS_ORG_0205_MWI NLIMS_ORG_0206_MWI NLIMS_ORG_0207_MWI])
      end

      def pseudomonas_spp
        GlobalService.fetch_ids(Organism,
                                ['Pseudomonas', 'Pseudomonas aeruginosa', 'Pseudomonas psudomallei', 'Pseudomonas species'], %w[NLIMS_ORG_0011_MWI NLIMS_ORG_0004_MWI NLIMS_ORG_0175_MWI NLIMS_ORG_0177_MWI])
      end

      def strept_pneumoniae
        GlobalService.fetch_ids(Organism, ['Streptococcus pneumoniae', 'S.pneumoniae'],
                                %w[NLIMS_ORG_0003_MWI NLIMS_ORG_0008_MWI])
      end

      def strept_a_b
        GlobalService.fetch_ids(Organism,
                                ['ß-hemolytic streptococci', 'Streptococcus agalactiae', 'Streptococcus pyogenes'], %w[NLIMS_ORG_0153_MWI NLIMS_ORG_0007_MWI NLIMS_ORG_0140_MWI])
      end

      def enterococcus_spp
        GlobalService.fetch_ids(Organism, ['Enterococcus casseliflavus', '	Enterococcus durans', 'Enterococcus faecalis', '	Enterococcus faecium', 'Enterococcus gallinarum', 'Enterococcus species'],
                                %w[NLIMS_ORG_0120_MWI NLIMS_ORG_0122_MWI NLIMS_ORG_0124_MWI NLIMS_ORG_0126_MWI NLIMS_ORG_0127_MWI NLIMS_ORG_0129_MWI])
      end

      def staphylococcus_aureus
        GlobalService.fetch_ids(Organism, ['Staphylcoccus aureus'], %w[NLIMS_ORG_0134_MWI])
      end

      def neisseria_spp
        GlobalService.fetch_ids(Organism, ['Neisseria meningitides', 'Neisseria gonorrhoeae', 'Neisseria lactamica', 'Neisseria meningitidis', 'Neisseria species'],
                                %w[NLIMS_ORG_0005_MWI NLIMS_ORG_0121_MWI NLIMS_ORG_0123_MWI NLIMS_ORG_0125_MWI NLIMS_ORG_0128_MWI])
      end

      def shigella_spp
        GlobalService.fetch_ids(Organism,
                                ['Shigella species', 'Shigella boydii', 'Shigella dysenteriae', 'Shigella flexneri', 'Shigella sonnei'], %w[NLIMS_ORG_0133_MWI NLIMS_ORG_0212_MWI NLIMS_ORG_0213_MWI NLIMS_ORG_0214_MWI NLIMS_ORG_0215_MWI])
      end

      def cryptococcus_spp
        GlobalService.fetch_ids(Organism, ['Cryptococcus neoformans', 'Cryptococcus species'],
                                %w[NLIMS_ORG_0106_MWI NLIMS_ORG_0108_MWI])
      end

      def amoxicillin_clavulanic_acid_ids
        GlobalService.fetch_ids(Drug, ['Amoxicillin/Clavulanate'],
                                %w[NLIMS_DRG_0001_MWI])
      end

      def ampicillin_ids
        GlobalService.fetch_ids(Drug, ['Ampicillin'], %w[NLIMS_DRG_0002_MWI])
      end

      def piperacillin_tazobactum_ids
        GlobalService.fetch_ids(Drug,
                                ['Piperacillin/Tazobactam'], %w[NLIMS_DRG_0016_MWI])
      end

      def cefoxitin_ids
        GlobalService.fetch_ids(Drug, ['Cefoxitin'], %w[NLIMS_DRG_0020_MWI])
      end

      def ceftriaxone_ids
        GlobalService.fetch_ids(Drug, ['Ceftriaxone'], %w[NLIMS_DRG_0003_MWI])
      end

      def ceftazidime_ids
        GlobalService.fetch_ids(Drug, ['Ceftazidime'], %w[NLIMS_DRG_0014_MWI])
      end

      def cefotaxime_ids
        GlobalService.fetch_ids(Drug, ['Cefotaxime'], %w[NLIMS_DRG_0018_MWI])
      end

      def meropenem_ids
        GlobalService.fetch_ids(Drug, ['Meropenem'], %w[NLIMS_DRG_0027_MWI])
      end

      def ciplofloxacin_ids
        GlobalService.fetch_ids(Drug, %w[Ciplofloxacin Ciprofloxacin], %w[NLIMS_DRG_0005_MWI])
      end

      def gentamicin_ids
        GlobalService.fetch_ids(Drug, ['Gentamicin'], %w[NLIMS_DRG_0010_MWI])
      end

      def tobramycin_ids
        GlobalService.fetch_ids(Drug, ['Tobramycin'], %w[NLIMS_DRG_0028_MWI])
      end

      def vancomycin_ids
        GlobalService.fetch_ids(Drug, ['Vancomycin'], %w[NLIMS_DRG_0019_MWI])
      end

      def erythromycin_ids
        GlobalService.fetch_ids(Drug, ['Erythromycin'], %w[NLIMS_DRG_0009_MWI])
      end

      def amikacin_ids
        GlobalService.fetch_ids(Drug, ['Amikacin'], %w[NLIMS_DRG_0023_MWI])
      end

      def other_spp
        spp = e_coli + klebsiella_spp + acinetobacter_spp + proteus_spp + salmonella_spp + pseudomonas_spp + strept_pneumoniae +
              strept_a_b + enterococcus_spp + staphylococcus_aureus + neisseria_spp + shigella_spp + cryptococcus_spp
        spp_ids = spp.gsub(/[()]/, '').split(',').map { |n| n.strip.to_i }
        other_orgs = Organism.where.not(id: spp_ids)
        GlobalService.fetch_ids(Organism, other_orgs.pluck(:name), other_orgs.pluck(:nlims_code))
      end
    end
  end
end
