# frozen_string_literal: true

# reports module
module Reports
  # Moh reports module
  module Moh
    # Helper module for calculating indicator counts
    module MigrationHelpers
      # Calculate the counts BloodBank indicators
      module BloodBankIndicatorCalculations
        def calculate_blood_grouping_done_on_patients
          <<-RUBY
            COUNT(DISTINCT CASE
              WHEN test_type = 'ABO Blood Grouping' AND status_id IN (4, 5) AND result IS NOT NULL
              THEN test_id
            END)
          RUBY
        end

        def calculate_total_x_matched
          <<-RUBY
            COUNT(DISTINCT CASE
              WHEN test_type = 'Cross-match' AND status_id IN (4, 5) AND result IS NOT NULL 
              THEN test_id
            END)
          RUBY
        end

        def calculate_x_matched_for_matenity
          <<-RUBY
            COUNT(DISTINCT CASE
              WHEN test_type = 'Cross-match' AND status_id IN (4, 5) AND result IS NOT NULL AND
              ward IN ('Labour', 'Labour Ward', 'EM LW', 'Maternity','PNW', '2A', '2B', '3A', '3B', 'LW', 'Maternity Ward')
              THEN test_id
            END)
          RUBY
        end

        def calculate_x_matched_for_peads
          <<-RUBY
            COUNT(DISTINCT CASE
              WHEN test_type = 'Cross-match' AND status_id IN (4, 5) AND result IS NOT NULL AND
              ward IN ('CWA', 'CWB', 'CWC', 'EM Nursery', 'Under 5 Clinic', 'ward 9','Paediatric Ward','Paeds Neuro',
                'Nursery', 'Paediatric', 'Peads Special Care Ward', 'Paeds Medical','Peads Isolation Centre', 'Paediatric Surgical', 'Paediatric Medical','Paeds Orthopedic',
                'Peads Moyo', 'Peads Nursery', 'Peads Oncology', 'Peads Orthopeadics', 'Peads Surgical Ward', 'Mercy James Paediatric Centre')
              THEN test_id
            END)
          RUBY
        end

        def calculate_x_matched_for_others
          <<-RUBY
            COUNT(DISTINCT CASE
              WHEN test_type = 'Cross-match' AND status_id IN (4, 5) AND result IS NOT NULL
              AND ward IN ('Others', 'Other')
              THEN test_id
            END)
          RUBY
        end

        def calculate_x_matches_done_on_patients_with_hb_6_0g_dl
          <<-RUBY
            COUNT(DISTINCT CASE WHEN test_type IN ('FBC', 'FBC (Paeds)', 'Hemoglobin', 'Heamoglobin','Haemoglobin')#{' '}
            AND test_indicator_name IN ('Hemoglobin','Haemoglobin','HGB', 'Hb') AND result <= 6 THEN#{' '}
            (CASE WHEN test_type = 'Cross-match' AND test_indicator_name = 'Pack ABO Group' AND status_id IN (4, 5) AND result IS NOT NULL THEN test_id END)
            END)
          RUBY
        end

        def calculate_x_matches_done_on_patients_with_hb_6_0_g_dl
          <<-RUBY
            COUNT(DISTINCT CASE WHEN test_type IN ('FBC', 'FBC (Paeds)', 'Hemoglobin', 'Heamoglobin','Haemoglobin')#{' '}
            AND test_indicator_name IN ('Hemoglobin','Haemoglobin','HGB', 'Hb') AND result > 6 THEN#{' '}
            (CASE WHEN test_type = 'Cross-match' AND test_indicator_name = 'Pack ABO Group' AND status_id IN (4, 5) AND result IS NOT NULL THEN test_id END)
            END)
          RUBY
        end

        def calculate_total_number_transfused_with_platelets
          <<-RUBY
            COUNT(DISTINCT CASE
            WHEN test_type = 'Cross-match' AND status_id IN (4, 5) AND result IS NOT NULL AND
            test_indicator_name = 'Product Type' AND result = 'Platelets'
            THEN test_id END)
          RUBY
        end

        def calculate_total_number_transfused_with_whole_blood
          <<-RUBY
            COUNT(DISTINCT CASE
            WHEN test_type = 'Cross-match' AND status_id IN (4, 5) AND result IS NOT NULL AND
            test_indicator_name = 'Product Type' AND result = 'Whole Blood'
            THEN test_id END)
          RUBY
        end

        def calculate_total_number_transfused_with_packed_cells
          <<-RUBY
            COUNT(DISTINCT CASE
            WHEN test_type = 'Cross-match' AND status_id IN (4, 5) AND result IS NOT NULL AND
            test_indicator_name = 'Product Type' AND result IN ('Packed Red Cells','RED BLOOD CELLS')
            THEN test_id END)
          RUBY
        end

        def calculate_total_number_transfused_with_ffp
          <<-RUBY
            COUNT(DISTINCT CASE
            WHEN test_type = 'Cross-match' AND status_id IN (4, 5) AND result IS NOT NULL AND
            test_indicator_name = 'Product Type' AND result = 'FFPs'
            THEN test_id END)
          RUBY
        end

        def calculate_total_number_transfused_with_cryo_precipitate
          <<-RUBY
            COUNT(DISTINCT CASE
            WHEN test_type = 'Cross-match' AND status_id IN (4, 5) AND result IS NOT NULL AND
            test_indicator_name = 'Product Type' AND result = 'Cryoprecipitate'
            THEN test_id END)
          RUBY
        end 
      end
    end
  end
end
