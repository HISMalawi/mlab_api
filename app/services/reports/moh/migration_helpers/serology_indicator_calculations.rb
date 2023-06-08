# frozen_string_literal: true

# reports module
module Reports
  # Moh reports module
  module Moh
    # Helper module for calculating indicator counts
    module MigrationHelpers
      # Calculate the counts Serology indicators
      module SerologyIndicatorCalculations
        def calculate_syphilis_screening_on_patients
          <<-RUBY
            COUNT(DISTINCT CASE
              WHEN test_type IN ('Syphilis Test', 'Syphilis (Paeds)') AND status_id IN (4, 5) AND result IS NOT NULL THEN test_id
            END)
          RUBY
        end

        def calculate_syphilis_positive_tests
          <<-RUBY
            COUNT(DISTINCT CASE
              WHEN test_type IN ('Syphilis Test', 'Syphilis (Paeds)') AND test_indicator_name IN ('RPR', 'VDRL', 'TPHA')
              AND result = 'REACTIVE' AND status_id IN (4, 5) AND result IS NOT NULL THEN test_id
            END)
          RUBY
        end

        def calculate_syphilis_screening_on_antenatal_mothers
          <<-RUBY
            COUNT(DISTINCT CASE
              WHEN test_type IN ('Syphilis Test') AND test_indicator_name IN ('RPR', 'VDRL', 'TPHA')
              AND ward IN ('EM THEATRE','Labour', 'Labour Ward', 'EM LW', 'Maternity','PNW', '2A', '2B',
              '3A', '3B', 'LW', 'Maternity Ward', 'Antenatal','ANC') AND status_id IN (4, 5) AND result IS NOT NULL THEN test_id
            END)
          RUBY
        end

        def calculate_syphilis_positive_tests_on_antenatal_mothers
          <<-RUBY
            COUNT(DISTINCT CASE
              WHEN test_type IN ('Syphilis Test') AND test_indicator_name IN ('RPR', 'VDRL', 'TPHA')
              AND ward IN ('EM THEATRE','Labour', 'Labour Ward', 'EM LW', 'Maternity','PNW', '2A', '2B',
              '3A', '3B', 'LW', 'Maternity Ward', 'Antenatal','ANC') AND result = 'REACTIVE' AND status_id IN (4, 5) AND result IS NOT NULL THEN test_id
            END)
          RUBY
        end

        def calculate_hepbsag_test_done_on_patients
          <<-RUBY
            COUNT(DISTINCT CASE
              WHEN test_type IN ('Hepatitis B Test', 'Hepatitis B test (Paeds)', 'Hepatitis C') AND status_id IN (4, 5) AND result IS NOT NULL THEN test_id
            END)
          RUBY
        end

        def calculate_hepbsag_positive_tests
          <<-RUBY
            COUNT(DISTINCT CASE
              WHEN test_type IN ('Hepatitis B Test', 'Hepatitis B test (Paeds)', 'Hepatitis C')
              AND result ='Positive' AND status_id IN (4, 5) AND result IS NOT NULL THEN test_id
            END)
          RUBY
        end

        def calculate_hepccag_test_done_on_patients
          <<-RUBY
            COUNT(DISTINCT CASE
              WHEN test_type IN ('Hepatitis C Test', 'Hepatitis C test (Paeds)', 'Hepatitis C') AND status_id IN (4, 5) AND result IS NOT NULL THEN test_id
            END)
          RUBY
        end

        def calculate_hepccag_positive_tests
          <<-RUBY
            COUNT(DISTINCT CASE
              WHEN test_type IN ('Hepatitis C Test', 'Hepatitis C test (Paeds)', 'Hepatitis C')
              AND result ='Positive' AND status_id IN (4, 5) AND result IS NOT NULL THEN test_id
            END)
          RUBY
        end

        def calculate_hcg_pregnacy_tests_done
          <<-RUBY
            COUNT(DISTINCT CASE
              WHEN test_type = 'Pregnancy Test' AND status_id IN (4, 5) AND result IS NOT NULL THEN test_id
            END)
          RUBY
        end

        def calculate_hcg_pregnacy_positive_tests
          <<-RUBY
            COUNT(DISTINCT CASE
              WHEN test_type = 'Pregnancy Test' AND result = 'Positive' AND status_id IN (4, 5) AND result IS NOT NULL THEN test_id
            END)
          RUBY
        end

        def calculate_hiv_tests_on_pep_patients
          <<-RUBY
            COUNT(DISTINCT CASE
              WHEN test_type IN ('HIV', 'HIV TEST', 'HIV Antibody Tests') AND status_id IN (4, 5) AND result IS NOT NULL THEN test_id
            END)
          RUBY
        end

        def calculate_hiv_pep_positives_tests
          <<-RUBY
            COUNT(DISTINCT CASE
              WHEN test_type IN ('HIV', 'HIV TEST', 'HIV Antibody Tests')
               AND result IN ('Positive', 'Reactive') AND status_id IN (4, 5) AND result IS NOT NULL THEN test_id
            END)
          RUBY
        end

        def calculate_prostate_specific_antigen_psa_tests
          <<-RUBY
            COUNT(DISTINCT CASE
              WHEN test_type IN ('PSA', 'Prostate Specific Antigens', 'Total Prostrate Specific Antigen',
                 'Free Prostrate Specific Antigen') AND status_id IN (4, 5) AND result IS NOT NULL THEN test_id
            END)
          RUBY
        end

        def calculate_psa_positive
          <<-RUBY
            COUNT(DISTINCT CASE
              WHEN test_type IN ('PSA', 'Prostate Specific Antigens', 'Total Prostrate Specific Antigen',
              'Free Prostrate Specific Antigen') AND result > 4 AND status_id IN (4, 5) AND result IS NOT NULL THEN test_id
            END)
          RUBY
        end

        def calculate_sars_covid_19_rapid_antigen_tests
          <<-RUBY
            COUNT(DISTINCT CASE
              WHEN test_type = 'SARS COV-2 Rapid Antigen' AND status_id IN (4, 5) AND result IS NOT NULL THEN test_id
            END)
          RUBY
        end

        def calculate_sars_covid_19_positive
          <<-RUBY
            COUNT(DISTINCT CASE
              WHEN test_type = 'SARS COV-2 Rapid Antigen' AND result = 'Positive' AND status_id IN (4, 5) AND result IS NOT NULL THEN test_id
            END)
          RUBY
        end

        def calculate_serum_crag
          <<-RUBY
            COUNT(DISTINCT CASE
              WHEN test_type = 'Serum CrAg' AND result > 4 AND status_id IN (4, 5) AND result IS NOT NULL THEN test_id
            END)
          RUBY
        end

        def calculate_serum_crag_positive
          <<-RUBY
            COUNT(DISTINCT CASE
              WHEN test_type = 'Serum CrAg' AND result = 'Positive' AND status_id IN (4, 5) AND result IS NOT NULL THEN test_id
            END)
          RUBY
        end
      end
    end
  end
end
