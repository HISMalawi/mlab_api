# frozen_string_literal: true

# reports module
module Reports
  # Moh reports module
  module Moh
    # Helper module for calculating indicator counts
    module MigrationHelpers
      # Calculate the counts Haematology indicators
      module HaematologyIndicatorCalculations
        def calculate_full_blood_count
          <<-RUBY
        COUNT(DISTINCT CASE
          WHEN test_type IN ('FBC', 'FBC (Paeds)') AND status_id IN (4, 5) AND result IS NOT NULL THEN test_id
        END)
          RUBY
        end

        def calculate_heamoglobin_only_blood_donors_excluded
          <<-RUBY
        COUNT(DISTINCT CASE
          WHEN test_type IN ('FBC', 'FBC (Paeds)') AND test_indicator_name = 'HGB' AND status_id IN (4, 5) AND result IS NOT NULL THEN test_id
        END)
          RUBY
        end

        def calculate_heamoglobin_only_hemacue
          <<-RUBY
        COUNT(DISTINCT CASE WHEN test_type IN ('Hemoglobin', 'Heamoglobin','Haemoglobin')
        AND test_indicator_name IN ('Hemoglobin','Haemoglobin','HGB', 'Hb') AND status_id IN (4, 5) AND result IS NOT NULL THEN test_id END)
          RUBY
        end

        def calculate_patients_with_hb_6_0g_dl
          <<-RUBY
        COUNT(DISTINCT CASE WHEN test_type IN ('FBC', 'FBC (Paeds)', 'Hemoglobin', 'Heamoglobin','Haemoglobin')#{' '}
        AND test_indicator_name IN ('Hemoglobin','Haemoglobin','HGB', 'Hb') AND result <= 6 AND status_id IN (4, 5) AND result IS NOT NULL THEN test_id END)
          RUBY
        end

        def calculate_patients_with_hb_6_0g_dl_who_were_transfused
          <<-RUBY
        COUNT(DISTINCT CASE WHEN test_type IN ('FBC', 'FBC (Paeds)', 'Hemoglobin', 'Heamoglobin','Haemoglobin')#{' '}
        AND test_indicator_name IN ('Hemoglobin','Haemoglobin','HGB', 'Hb') AND result <= 6 THEN#{' '}
        (CASE WHEN test_type = 'Cross-match' AND test_indicator_name = 'Pack ABO Group' AND status_id IN (4, 5) AND result IS NOT NULL THEN test_id END)
        END)
          RUBY
        end

        def calculate_patients_with_hb_6_0_g_dl
          <<-RUBY
          COUNT(DISTINCT CASE WHEN test_type IN ('FBC', 'FBC (Paeds)', 'Hemoglobin', 'Heamoglobin','Haemoglobin')#{' '}
            AND test_indicator_name IN ('Hemoglobin','Haemoglobin','HGB', 'Hb') AND result > 6 AND status_id IN (4, 5) AND result IS NOT NULL THEN test_id END)
          RUBY
        end

        def calculate_patients_with_hb_6_0_g_dl_who_were_transfused
          <<-RUBY
          COUNT(DISTINCT CASE WHEN test_type IN ('FBC', 'FBC (Paeds)', 'Hemoglobin', 'Heamoglobin','Haemoglobin')#{' '}
            AND test_indicator_name IN ('Hemoglobin','Haemoglobin','HGB', 'Hb') AND result > 6 THEN#{' '}
            (CASE WHEN test_type = 'Cross-match' AND test_indicator_name = 'Pack ABO Group' AND status_id IN (4, 5) AND result IS NOT NULL THEN test_id END)
            END)#{' '}
          RUBY
        end

        def calculate_wbc_manual_count
          <<-RUBY
          COUNT(DISTINCT CASE WHEN test_type = 'Manual Differential & Cell Morphology' AND status_id IN (4, 5) AND result IS NOT NULL THEN test_id END)
          RUBY
        end

        def calculate_manual_wbc_differential
          <<-RUBY
      COUNT(DISTINCT CASE WHEN test_type = 'Manual Differential & Cell Morphology' AND status_id IN (4, 5) AND result IS NOT NULL THEN test_id END)
          RUBY
        end

        def calculate_blood_film_for_red_cell_morphology
          <<-RUBY
      COUNT(DISTINCT CASE WHEN test_type = 'Manual Differential & Cell Morphology' AND status_id IN (4, 5) AND result IS NOT NULL THEN test_id END)
          RUBY
        end

        def calculate_erythrocyte_sedimentation_rate_esr
          <<-RUBY
          COUNT(DISTINCT CASE WHEN test_type IN ('ESR','ESR Peads') AND status_id IN (4, 5) AND result IS NOT NULL THEN test_id END)
          RUBY
        end

        def calculate_sickling_test
          <<-RUBY
          COUNT(DISTINCT CASE WHEN test_type = 'Sickling Test' AND status_id IN (4, 5) AND result IS NOT NULL THEN test_id END)
          RUBY
        end

        def calculate_reticulocyte_count
          <<-RUBY
          COUNT(DISTINCT CASE WHEN test_type IN ('FBC', 'FBC (Paeds)') AND test_indicator_name = 'RET#' AND status_id IN (4, 5) AND result IS NOT NULL THEN test_id END)
          RUBY
        end

        def calculate_prothrombin_time_pt
          <<-RUBY
          COUNT(DISTINCT CASE WHEN test_type = 'Prothrombin Time' AND status_id IN (4, 5) AND result IS NOT NULL THEN test_id END)
          RUBY
        end

        def calculate_activated_partial_thromboplastin_time_aptt
          <<-RUBY
          COUNT(DISTINCT CASE WHEN test_type = 'APTT' AND status_id IN (4, 5) AND result IS NOT NULL THEN test_id END)
          RUBY
        end

        def calculate_international_normalized_ratio_inr
          <<-RUBY
          COUNT(DISTINCT CASE WHEN test_type = 'INR' AND status_id IN (4, 5) AND result IS NOT NULL THEN test_id END)
          RUBY
        end

        def calculate_bleeding_cloting_time
          <<-RUBY
          COUNT(DISTINCT CASE WHEN test_type = 'Bleeding Time'  AND status_id IN (4, 5) AND result IS NOT NULL THEN test_id END)
          RUBY
        end

        def calculate_cd4_absolute_count
          <<-RUBY
          COUNT(DISTINCT CASE WHEN test_type = 'CD4' AND test_indicator_name = 'CD4 Count' AND status_id IN (4, 5) AND result IS NOT NULL THEN test_id END)
          RUBY
        end

        def calculate_cd4_percentage
          <<-RUBY
          COUNT(DISTINCT CASE WHEN test_type = 'CD4' AND test_indicator_name = 'CD4 %' AND status_id IN (4, 5) AND result IS NOT NULL THEN test_id END)
          RUBY
        end
      end
    end
  end
end
