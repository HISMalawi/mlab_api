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
              THEN test_id
            END)
          RUBY
        end

        def calculate_number_of_new_tb_cases_examined
          <<-RUBY
            COUNT(DISTINCT CASE
              WHEN test_type IN ('TB Tests', 'TB Microscopy','TB', 'TB_Microscopy', 'TB Gene_Xpert')
              AND test_indicator_name IN ('Smear microscopy result','Smear microscopy result 1')
              THEN test_id
            END)
          RUBY
        end

        def calculate_new_cases_with_positive_smear
          <<-RUBY
            COUNT(DISTINCT CASE
              WHEN test_type IN ('TB Tests', 'TB Microscopy','TB', 'TB_Microscopy', 'TB Gene_Xpert')
              AND test_indicator_name IN ('Smear microscopy result','Smear microscopy result 1')
              AND (result LIKE '%+%' OR result LIKE '%Scanty%' OR result = 'Positive')
              THEN test_id
            END)
          RUBY
        end

        def calculate_tb_lam_total
          <<-RUBY
            COUNT(DISTINCT CASE
              WHEN test_type IN ('TB LAM', 'Urine Lam')
              THEN test_id
            END)
          RUBY
        end

        def calculate_tb_lam_positive
          <<-RUBY
            COUNT(DISTINCT CASE
              WHEN test_type IN ('TB LAM', 'Urine Lam') AND result IN ('Positive', 'Postive')
              THEN test_id
            END)
          RUBY
        end

        def calculate_mtb_not_detected
          <<-RUBY
            COUNT(DISTINCT CASE
              WHEN test_type IN ('TB Tests', 'TB Microscopy','TB', 'TB_Microscopy', 'TB Gene_Xpert')
              AND test_indicator_name = 'Gene Xpert MTB' AND result LIKE '%NOT%'
              THEN test_id
            END)
          RUBY
        end

        def calculate_mtb_detected
          <<-RUBY
            COUNT(DISTINCT CASE
              WHEN test_type IN ('TB Tests', 'TB Microscopy','TB', 'TB_Microscopy', 'TB Gene_Xpert')
              AND test_indicator_name = 'Gene Xpert MTB' AND (result NOT LIKE '%NOT%' AND result LIKE '%DETECTED%')
              THEN test_id
            END)
          RUBY
        end

        def calculate_rif_resistant_detected
          <<-RUBY
            COUNT(DISTINCT CASE
              WHEN test_type IN ('TB Tests', 'TB Microscopy','TB', 'TB_Microscopy', 'TB Gene_Xpert')
              AND test_indicator_name = 'Gene Xpert RIF Resistance' AND (result NOT LIKE '%NOT%' AND result LIKE '%DETECTED%')
              THEN test_id
            END)
          RUBY
        end

        def calculate_rif_resistant_not_detected
          <<-RUBY
            COUNT(DISTINCT CASE
              WHEN test_type IN ('TB Tests', 'TB Microscopy','TB', 'TB_Microscopy', 'TB Gene_Xpert')
              AND test_indicator_name = 'Gene Xpert RIF Resistance' AND result LIKE '%NOT%'
              THEN test_id
            END)
          RUBY
        end

        def calculate_rif_resistant_indeterminate
          <<-RUBY
            COUNT(DISTINCT CASE
              WHEN test_type IN ('TB Tests', 'TB Microscopy','TB', 'TB_Microscopy', 'TB Gene_Xpert')
              AND test_indicator_name = 'Gene Xpert RIF Resistance' AND result LIKE '%Indetermi%'
              THEN test_id
            END)
          RUBY
        end

        def calculate_invalid
          <<-RUBY
            COUNT(DISTINCT CASE
              WHEN test_type IN ('TB Tests', 'TB Microscopy','TB', 'TB_Microscopy', 'TB Gene_Xpert')
              AND test_indicator_name = 'Gene Xpert MTB' AND result LIKE '%Invalid%'
              THEN test_id
            END)
          RUBY
        end

        def calculate_no_results
          <<-RUBY
            COUNT(DISTINCT CASE
              WHEN test_type IN ('TB Tests', 'TB Microscopy','TB', 'TB_Microscopy', 'TB Gene_Xpert')
              AND test_indicator_name = 'Gene Xpert MTB' AND result LIKE '%No result%'
              THEN test_id
            END)
          RUBY
        end

        def calculate_total_number_of_covid_19_tests_performed
          <<-RUBY
            COUNT(DISTINCT CASE
              WHEN test_type IN ('SARS COV 19','SARS Cov 2','SARS-CoV-2', 'SARS COV-2 Rapid Antigen')
              THEN test_id
            END)
          RUBY
        end

        def calculate_total_number_of_sars_cov2_positive
          <<-RUBY
            COUNT(DISTINCT CASE
              WHEN test_type IN ('SARS COV 19','SARS Cov 2','SARS-CoV-2', 'SARS COV-2 Rapid Antigen')
              AND result = 'Positive' THEN test_id
            END)
          RUBY
        end
        
        def calculate_total_number_of_invalid_sars_cov2_results
          <<-RUBY
            COUNT(DISTINCT CASE
              WHEN test_type IN ('SARS COV 19','SARS Cov 2','SARS-CoV-2', 'SARS COV-2 Rapid Antigen')
              AND result = 'Invalid' THEN test_id
            END)
          RUBY
        end

        def calculate_total_number_of_no_results
          <<-RUBY
            COUNT(DISTINCT CASE
              WHEN test_type IN ('SARS COV 19','SARS Cov 2','SARS-CoV-2', 'SARS COV-2 Rapid Antigen')
              AND result = 'NO RESULTS' THEN test_id
            END)
          RUBY
        end

        def calculate_total_number_of_error_results
          <<-RUBY
            COUNT(DISTINCT CASE
              WHEN test_type IN ('SARS COV 19','SARS Cov 2','SARS-CoV-2', 'SARS COV-2 Rapid Antigen')
              AND result = 'ERROR' THEN test_id
            END)
          RUBY
        end

        def calculate_dna_eid_samples_received
          <<-RUBY
            COUNT(DISTINCT CASE
              WHEN test_type = 'Early Infant Diagnosis'
              AND status_id = 1 THEN test_id
            END)
          RUBY
        end

        def calculate_dna_eid_tests_done
          <<-RUBY
            COUNT(DISTINCT CASE
              WHEN test_type = 'Early Infant Diagnosis'
              AND status_id IN (4,5) THEN test_id
            END)
          RUBY
        end
      end
    end
  end
end
