# frozen_string_literal: true

# reports module
module Reports
  # Moh reports module
  module Moh
    # Helper module for calculating indicator counts
    module MigrationHelpers
      # Calculate the counts Microbiology indicators
      module MicrobiologyIndicatorCalculations
        def calculate_number_of_afb_sputum_examined
          <<-RUBY
            COUNT(DISTINCT CASE
              WHEN test_type IN ('TB Tests', 'TB Microscopy','TB', 'TB_Microscopy', 'TB Gene_Xpert')
              AND test_indicator_name IN ('Smear microscopy result','Smear microscopy result 1')
              AND status_id IN (4, 5) AND result IS NOT NULL THEN test_id
            END)
          RUBY
        end

        def calculate_number_of_new_tb_cases_examined
          <<-RUBY
            COUNT(DISTINCT CASE
              WHEN test_type IN ('TB Tests', 'TB Microscopy','TB', 'TB_Microscopy', 'TB Gene_Xpert')
              AND test_indicator_name IN ('Smear microscopy result','Smear microscopy result 1')
              AND status_id IN (4, 5) AND result IS NOT NULL THEN test_id
            END)
          RUBY
        end

        def calculate_new_cases_with_positive_smear
          <<-RUBY
            COUNT(DISTINCT CASE
              WHEN test_type IN ('TB Tests', 'TB Microscopy','TB', 'TB_Microscopy', 'TB Gene_Xpert')
              AND test_indicator_name IN ('Smear microscopy result','Smear microscopy result 1')
              AND (result LIKE '%+%' OR result LIKE '%Scanty%' OR result = 'Positive')
              AND status_id IN (4, 5) AND result IS NOT NULL THEN test_id
            END)
          RUBY
        end

        def calculate_tb_lam_total
          <<-RUBY
            COUNT(DISTINCT CASE
              WHEN test_type IN ('TB LAM', 'Urine Lam')
              AND status_id IN (4, 5) AND result IS NOT NULL THEN test_id
            END)
          RUBY
        end

        def calculate_tb_lam_positive
          <<-RUBY
            COUNT(DISTINCT CASE
              WHEN test_type IN ('TB LAM', 'Urine Lam') AND result IN ('Positive', 'Postive')
              AND status_id IN (4, 5) AND result IS NOT NULL THEN test_id
            END)
          RUBY
        end

        def calculate_mtb_not_detected
          <<-RUBY
            COUNT(DISTINCT CASE
              WHEN test_type IN ('TB Tests', 'TB Microscopy','TB', 'TB_Microscopy', 'TB Gene_Xpert')
              AND test_indicator_name = 'Gene Xpert MTB' AND result LIKE '%NOT%'
              AND status_id IN (4, 5) AND result IS NOT NULL THEN test_id
            END)
          RUBY
        end

        def calculate_mtb_detected
          <<-RUBY
            COUNT(DISTINCT CASE
              WHEN test_type IN ('TB Tests', 'TB Microscopy','TB', 'TB_Microscopy', 'TB Gene_Xpert')
              AND test_indicator_name = 'Gene Xpert MTB' AND (result NOT LIKE '%NOT%' AND result LIKE '%DETECTED%')
              AND status_id IN (4, 5) AND result IS NOT NULL THEN test_id
            END)
          RUBY
        end

        def calculate_rif_resistant_detected
          <<-RUBY
            COUNT(DISTINCT CASE
              WHEN test_type IN ('TB Tests', 'TB Microscopy','TB', 'TB_Microscopy', 'TB Gene_Xpert')
              AND test_indicator_name = 'Gene Xpert RIF Resistance' AND (result NOT LIKE '%NOT%' AND result LIKE '%DETECTED%')
              AND status_id IN (4, 5) AND result IS NOT NULL THEN test_id
            END)
          RUBY
        end

        def calculate_rif_resistant_not_detected
          <<-RUBY
            COUNT(DISTINCT CASE
              WHEN test_type IN ('TB Tests', 'TB Microscopy','TB', 'TB_Microscopy', 'TB Gene_Xpert')
              AND test_indicator_name = 'Gene Xpert RIF Resistance' AND result LIKE '%NOT%'
              AND status_id IN (4, 5) AND result IS NOT NULL THEN test_id
            END)
          RUBY
        end

        def calculate_rif_resistant_indeterminate
          <<-RUBY
            COUNT(DISTINCT CASE
              WHEN test_type IN ('TB Tests', 'TB Microscopy','TB', 'TB_Microscopy', 'TB Gene_Xpert')
              AND test_indicator_name = 'Gene Xpert RIF Resistance' AND result LIKE '%Indetermi%'
              AND status_id IN (4, 5) AND result IS NOT NULL THEN test_id
            END)
          RUBY
        end

        def calculate_invalid
          <<-RUBY
            COUNT(DISTINCT CASE
              WHEN test_type IN ('TB Tests', 'TB Microscopy','TB', 'TB_Microscopy', 'TB Gene_Xpert')
              AND test_indicator_name = 'Gene Xpert MTB' AND result LIKE '%Invalid%'
              AND status_id IN (4, 5) AND result IS NOT NULL THEN test_id
            END)
          RUBY
        end

        def calculate_no_results
          <<-RUBY
            COUNT(DISTINCT CASE
              WHEN test_type IN ('TB Tests', 'TB Microscopy','TB', 'TB_Microscopy', 'TB Gene_Xpert')
              AND test_indicator_name = 'Gene Xpert MTB' AND result LIKE '%No result%'
              AND status_id IN (4, 5) AND result IS NOT NULL THEN test_id
            END)
          RUBY
        end

        def calculate_total_number_of_covid_19_tests_performed
          <<-RUBY
            COUNT(DISTINCT CASE
              WHEN test_type IN ('SARS COV 19','SARS Cov 2','SARS-CoV-2', 'SARS COV-2 Rapid Antigen')
              AND status_id IN (4, 5) AND result IS NOT NULL THEN test_id
            END)
          RUBY
        end

        def calculate_total_number_of_sars_cov2_positive
          <<-RUBY
            COUNT(DISTINCT CASE
              WHEN test_type IN ('SARS COV 19','SARS Cov 2','SARS-CoV-2', 'SARS COV-2 Rapid Antigen')
              AND result = 'Positive' AND status_id IN (4, 5) AND result IS NOT NULL THEN test_id
            END)
          RUBY
        end
        
        def calculate_total_number_of_invalid_sars_cov2_results
          <<-RUBY
            COUNT(DISTINCT CASE
              WHEN test_type IN ('SARS COV 19','SARS Cov 2','SARS-CoV-2', 'SARS COV-2 Rapid Antigen')
              AND result = 'Invalid' AND status_id IN (4, 5) AND result IS NOT NULL THEN test_id
            END)
          RUBY
        end

        def calculate_total_number_of_no_results
          <<-RUBY
            COUNT(DISTINCT CASE
              WHEN test_type IN ('SARS COV 19','SARS Cov 2','SARS-CoV-2', 'SARS COV-2 Rapid Antigen')
              AND result = 'NO RESULTS' AND status_id IN (4, 5) AND result IS NOT NULL THEN test_id
            END)
          RUBY
        end

        def calculate_total_number_of_error_results
          <<-RUBY
            COUNT(DISTINCT CASE
              WHEN test_type IN ('SARS COV 19','SARS Cov 2','SARS-CoV-2', 'SARS COV-2 Rapid Antigen')
              AND result = 'ERROR' AND status_id IN (4, 5) AND result IS NOT NULL THEN test_id
            END)
          RUBY
        end

        def calculate_dna_eid_samples_received
          <<-RUBY
            COUNT(DISTINCT CASE
              WHEN test_type = 'Early Infant Diagnosis'
              THEN test_id
            END)
          RUBY
        end

        def calculate_dna_eid_tests_done
          <<-RUBY
            COUNT(DISTINCT CASE
              WHEN test_type = 'Early Infant Diagnosis'
              AND status_id IN (4, 5) AND result IS NOT NULL THEN test_id
            END)
          RUBY
        end

        def calculate_number_with_positive_results
          <<-RUBY
            COUNT(DISTINCT CASE
              WHEN test_type = 'Early Infant Diagnosis' AND result NOT IN ('NO RESULT', 'ERROR', 'INVALID', 'NEGATIVE', 'h')
              AND result NOT LIKE '%NOT%'
              AND status_id IN (4, 5) AND result IS NOT NULL THEN test_id
            END)
          RUBY
        end

        def calculate_vl_samples_received
          <<-RUBY
            COUNT(DISTINCT CASE
              WHEN test_type = 'Viral Load' 
              THEN test_id
            END)
          RUBY
        end

        def calculate_vl_tests_done
          <<-RUBY
            COUNT(DISTINCT CASE
              WHEN test_type = 'Viral Load' 
              AND status_id IN (4, 5) AND result IS NOT NULL THEN test_id
            END)
          RUBY
        end

        def calculate_vl_results_with_less_than_1000_copies_per_ml
          <<-RUBY
            COUNT(DISTINCT CASE
              WHEN test_type = 'Viral Load' 
              AND REPLACE(result, ',', '') < 1000
              AND REPLACE(REPLACE(result, ',', '') , ' ', '') < 1000
              AND REPLACE(REPLACE(result, '<', ''), ' ', '') < 1000
              AND REPLACE(result,' ', '') < 1000
              AND result NOT IN ('NO RESULT', 'ERROR', 'INVALID')
              AND status_id IN (4, 5) AND result IS NOT NULL THEN test_id
            END)
          RUBY
        end

        def calculate_number_of_csf_samples_analysed
          <<-RUBY
            COUNT(DISTINCT CASE
              WHEN specimen = 'CSF'
              AND status_id IN (4, 5) AND result IS NOT NULL THEN test_id
            END)
          RUBY
        end

        def calculate_number_of_csf_samples_analysed_for_afb
          <<-RUBY
            COUNT(DISTINCT CASE
              WHEN specimen = 'CSF' AND test_type = 'TB Tests'
              AND status_id IN (4, 5) AND result IS NOT NULL THEN test_id
            END)
          RUBY
        end

        def calculate_number_of_csf_samples_with_organism
          <<-RUBY
            COUNT(DISTINCT CASE
              WHEN specimen = 'CSF' AND (result IN ('seen', 'growth') OR result LIKE '%positive%')
              AND status_id IN (4, 5) AND result IS NOT NULL THEN test_id
            END)
          RUBY
        end

        def calculate_number_of_csf_cultures_done
          <<-RUBY
            COUNT(DISTINCT CASE
              WHEN specimen = 'CSF' AND test_type IN ('Culture & Sensitivity', 'Culture & Sensitivity (Paeds)', 'Culture/sensistivity')
              AND status_id IN (4, 5) AND result IS NOT NULL THEN test_id
            END)
          RUBY
        end

        def calculate_positive_csf_cultures
          <<-RUBY
            COUNT(DISTINCT CASE
              WHEN specimen = 'CSF' AND test_type IN ('Culture & Sensitivity', 'Culture & Sensitivity (Paeds)', 'Culture/sensistivity')
              AND (result NOT LIKE '%Growth of normal%' AND result NOT IN ('No Growth', 'Growth of contaminants'))
              AND status_id IN (4, 5) AND result IS NOT NULL THEN test_id
            END)
          RUBY
        end

        def calculate_total_india_ink_done
          <<-RUBY
            COUNT(DISTINCT CASE
              WHEN test_type IN ('India Ink', 'India Ink (Paeds)')
              AND status_id IN (4, 5) AND result IS NOT NULL THEN test_id
            END)
          RUBY
        end

        def calculate_india_ink_positive
          <<-RUBY
            COUNT(DISTINCT CASE
              WHEN test_type IN ('India Ink', 'India Ink (Paeds)') AND result = 'Positive'
              AND status_id IN (4, 5) AND result IS NOT NULL THEN test_id
            END)
          RUBY
        end

        def calculate_gram_stain_positive
          <<-RUBY
            COUNT(DISTINCT CASE
              WHEN test_type IN ('Gram Stain', 'Gram Stain (Paeds)') AND result LIKE '%Positive%'
              AND status_id IN (4, 5) AND result IS NOT NULL THEN test_id
            END)
          RUBY
        end

        def calculate_total_gram_stain_done
          <<-RUBY
            COUNT(DISTINCT CASE
              WHEN test_type IN ('Gram Stain', 'Gram Stain (Paeds)')
              AND status_id IN (4, 5) AND result IS NOT NULL THEN test_id
            END)
          RUBY
        end

        def calculate_hvs_analysed
          <<-RUBY
            COUNT(DISTINCT CASE
              WHEN specimen = 'HVS'
              AND status_id IN (4, 5) AND result IS NOT NULL THEN test_id
            END)
          RUBY
        end

        def calculate_hvs_with_organism
          <<-RUBY
            COUNT(DISTINCT CASE
              WHEN specimen = 'HVS' AND (result IN ('seen', 'growth') OR result LIKE '%positive%')
              AND status_id IN (4, 5) AND result IS NOT NULL THEN test_id
            END)
          RUBY
        end

        def calculate_hvs_culture
          <<-RUBY
            COUNT(DISTINCT CASE
              WHEN specimen = 'HVS' AND test_type IN ('Culture & Sensitivity', 'Culture & Sensitivity (Paeds)', 'Culture/sensistivity')
              AND status_id IN (4, 5) AND result IS NOT NULL THEN test_id
            END)
          RUBY
        end

        def calculate_hvs_culture_positive
          <<-RUBY
            COUNT(DISTINCT CASE
              WHEN specimen = 'HVS' AND test_type IN ('Culture & Sensitivity', 'Culture & Sensitivity (Paeds)', 'Culture/sensistivity')
              AND ((result NOT LIKE '%Growth of normal%') AND result NOT IN ('No Growth', 'Growth of contaminants'))
              AND status_id IN (4, 5) AND result IS NOT NULL THEN test_id
            END)
          RUBY
        end

        def calculate_other_swabs_analysed
          <<-RUBY
            COUNT(DISTINCT CASE
              WHEN specimen = 'Swabs'
              AND status_id IN (4, 5) AND result IS NOT NULL THEN test_id
            END)
          RUBY
        end

        def calculate_other_swabs_with_organism
          <<-RUBY
            COUNT(DISTINCT CASE
              WHEN specimen = 'Swabs' AND (result IN ('seen', 'growth', 'AFB SEEN  SCANTY','Scanty AAFB seen') OR result LIKE '%positive%')
              AND status_id IN (4, 5) AND result IS NOT NULL THEN test_id
            END)
          RUBY
        end

        def calculate_other_swabs_culture
          <<-RUBY
            COUNT(DISTINCT CASE
              WHEN specimen = 'Swabs' AND test_type IN ('Culture & Sensitivity', 'Culture & Sensitivity (Paeds)', 'Culture/sensistivity')
              AND status_id IN (4, 5) AND result IS NOT NULL THEN test_id
            END)
          RUBY
        end

        def calculate_other_swabs_culture_positive
          <<-RUBY
            COUNT(DISTINCT CASE
              WHEN specimen = 'Swabs' AND test_type IN ('Culture & Sensitivity', 'Culture & Sensitivity (Paeds)', 'Culture/sensistivity')
              AND result NOT IN ('No Growth', 'Growth of contaminants')
              AND status_id IN (4, 5) AND result IS NOT NULL THEN test_id
            END)
          RUBY
        end

        def calculate_number_of_blood_cultures_done
          <<-RUBY
            COUNT(DISTINCT CASE
              WHEN specimen = 'Blood' AND test_type IN ('Culture & Sensitivity', 'Culture & Sensitivity (Paeds)', 'Culture/sensistivity')
              AND status_id IN (4, 5) AND result IS NOT NULL THEN test_id
            END)
          RUBY
        end

        def calculate_positive_blood_cultures
          <<-RUBY
            COUNT(DISTINCT CASE
              WHEN specimen = 'Blood' AND test_type IN ('Culture & Sensitivity', 'Culture & Sensitivity (Paeds)', 'Culture/sensistivity')
              AND result = 'Growth'
              AND status_id IN (4, 5) AND result IS NOT NULL THEN test_id
            END)
          RUBY
        end

        def calculate_cryptococcal_antigen_test
          <<-RUBY
            COUNT(DISTINCT CASE
              WHEN test_type = 'Cryptococcus Antigen Test'
              AND status_id IN (4, 5) AND result IS NOT NULL THEN test_id
            END)
          RUBY
        end

        def calculate_cryptococcal_antigen_test_positive
          <<-RUBY
            COUNT(DISTINCT CASE
              WHEN test_type = 'Cryptococcus Antigen Test' AND result = 'Positive'
              AND status_id IN (4, 5) AND result IS NOT NULL THEN test_id
            END)
          RUBY
        end

        def calculate_serum_crag
          <<-RUBY
            COUNT(DISTINCT CASE
              WHEN test_type = 'Serum CrAg'
              AND status_id IN (4, 5) AND result IS NOT NULL THEN test_id
            END)
          RUBY
        end

        def calculate_serum_crag_positive
          <<-RUBY
            COUNT(DISTINCT CASE
              WHEN test_type = 'Serum CrAg' AND result = 'Positive'
              AND status_id IN (4, 5) AND result IS NOT NULL THEN test_id
            END)
          RUBY
        end

        def calculate_total_number_of_fluids_analysed
          <<-RUBY
            COUNT(DISTINCT CASE
              WHEN specimen LIKE '%Fluid%'
              AND status_id IN (4, 5) AND result IS NOT NULL THEN test_id
            END)
          RUBY
        end

        def calculate_fluids_with_organisms
          <<-RUBY
            COUNT(DISTINCT CASE
              WHEN specimen LIKE '%Fluid%' AND test_type IN ('Culture & Sensitivity', 'Culture & Sensitivity (Paeds)', 'Culture/sensistivity')
              AND result = 'Growth'
              AND status_id IN (4, 5) AND result IS NOT NULL THEN test_id
            END)
          RUBY
        end

        def calculate_cholera_rapid_diagnostic_test_done
          <<-RUBY
            COUNT(DISTINCT CASE
              WHEN test_type IN ('Cholera', 'cholera rapid test', 'cholera rapoid test', 'Vibrio Cholerae', 'Cholera RDT') 
              AND test_indicator_name IN ('Rapid Test', 'cholera test', 'Cholera', 'Cholera RDT')
              AND status_id IN (4, 5) AND result IS NOT NULL THEN test_id
            END)
          RUBY
        end

        def calculate_positive_cholera_rapid_diagnostic_test
          <<-RUBY
            COUNT(DISTINCT CASE
              WHEN test_type IN ('Cholera', 'cholera rapid test', 'cholera rapoid test', 'Vibrio Cholerae', 'Cholera RDT') 
              AND test_indicator_name IN ('Rapid Test', 'cholera test', 'Cholera', 'Cholera RDT')
              AND result = 'Positive'
              AND status_id IN (4, 5) AND result IS NOT NULL THEN test_id
            END)
          RUBY
        end

        def calculate_cholera_cultures_done
          <<-RUBY
            COUNT(DISTINCT CASE
              WHEN test_type IN ('Cholera','Vibrio Cholerae') 
              AND test_indicator_name = 'Culture'
              AND status_id IN (4, 5) AND result IS NOT NULL THEN test_id
            END)
          RUBY
        end

        def calculate_positive_cholera_samples
          <<-RUBY
            COUNT(DISTINCT CASE
              WHEN test_type IN ('Cholera','Vibrio Cholerae') 
              AND test_indicator_name = 'Culture'
              AND result = 'Growth'
              AND status_id IN (4, 5) AND result IS NOT NULL THEN test_id
            END)
          RUBY
        end

        def calculate_other_stool_cultures
          <<-RUBY
            COUNT(DISTINCT CASE
              WHEN specimen  = 'Stool'
              AND test_indicator_name IN ('Culture & Sensitivity', 'Culture & Sensitivity (Paeds)', 'Culture/sensistivity')
              AND status_id IN (4, 5) AND result IS NOT NULL THEN test_id
            END)
          RUBY
        end

        def calculate_stool_samples_with_organisms_isolated_on_culture
          <<-RUBY
            COUNT(DISTINCT CASE
              WHEN specimen  = 'Stool'
              AND test_indicator_name IN ('Culture & Sensitivity', 'Culture & Sensitivity (Paeds)', 'Culture/sensistivity')
              AND result = 'Growth'
              AND status_id IN (4, 5) AND result IS NOT NULL THEN test_id
            END)
          RUBY
        end

        def calculate_urine_culture
          <<-RUBY
            COUNT(DISTINCT CASE
              WHEN specimen = 'Urine'
              AND test_indicator_name IN ('Culture & Sensitivity', 'Culture & Sensitivity (Paeds)', 'Culture/sensistivity')
              AND status_id IN (4, 5) AND result IS NOT NULL THEN test_id
            END)
          RUBY
        end

        def calculate_urine_culture_positive
          <<-RUBY
            COUNT(DISTINCT CASE
              WHEN specimen = 'Urine'
              AND test_indicator_name IN ('Culture & Sensitivity', 'Culture & Sensitivity (Paeds)', 'Culture/sensistivity')
              AND result = 'Growth'
              AND status_id IN (4, 5) AND result IS NOT NULL THEN test_id
            END)
          RUBY
        end
      end
    end
  end
end
