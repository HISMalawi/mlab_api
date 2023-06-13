# frozen_string_literal: true

# reports module
module Reports
  # Moh reports module
  module Moh
    # Helper module for calculating indicator counts
    module MigrationHelpers
      # Calculate the counts Parasitology indicators
      module ParasitologyIndicatorCalculations
        def calculate_total_malaria_microscopy_tests_done
          <<-RUBY
            COUNT(DISTINCT CASE
              WHEN test_type IN ('Malaria Screening', 'Malaria Screening (Paeds)', 'Malaria Blood Film') 
              AND test_indicator_name IN ('Blood film', 'Results','Malaria Species') AND status_id IN (4, 5) AND result IS NOT NULL THEN test_id
            END)
          RUBY
        end

        def calculate_total_positive_malaria_microscopy_tests_done
          <<-RUBY
            COUNT(DISTINCT CASE
              WHEN test_type IN ('Malaria Screening', 'Malaria Screening (Paeds)', 'Malaria Blood Film') 
              AND test_indicator_name IN ('Blood film', 'Results','Malaria Species') 
              AND result NOT IN ('NMPS', 'Negative', 'no malaria palasite seen', 'No malaria parasites seen', 
                'No tryps seen', 'No parasite seen', 'NPS') AND result NOT LIKE '%No parasi%'
              AND status_id IN (4, 5) AND result IS NOT NULL THEN test_id
            END)
          RUBY
        end

        def calculate_malaria_microscopy_in_5yrs
          <<-RUBY
            COUNT(DISTINCT CASE
              WHEN test_type IN ('Malaria Screening', 'Malaria Screening (Paeds)', 'Malaria Blood Film') 
              AND test_indicator_name IN ('Blood film', 'Results','Malaria Species') AND ((created_date - dob) <= 5) AND status_id IN (4, 5) AND result IS NOT NULL THEN test_id
            END)
          RUBY
        end

        def calculate_malaria_microscopy_in_5_yrs
          <<-RUBY
            COUNT(DISTINCT CASE
              WHEN test_type IN ('Malaria Screening', 'Malaria Screening (Paeds)', 'Malaria Blood Film') 
              AND test_indicator_name IN ('Blood film', 'Results','Malaria Species') AND ((created_date - dob) > 5) AND status_id IN (4, 5) AND result IS NOT NULL THEN test_id
            END)
          RUBY
        end

        def calculate_positive_malaria_slides_in_5yrs
          <<-RUBY
            COUNT(DISTINCT CASE
              WHEN test_type IN ('Malaria Screening', 'Malaria Screening (Paeds)', 'Malaria Blood Film') 
              AND test_indicator_name IN ('Blood film', 'Results','Malaria Species') AND ((created_date - dob) <= 5) 
              AND result NOT IN ('NMPS', 'Negative', 'no malaria palasite seen', 'No malaria parasites seen', 
                'No tryps seen', 'No parasite seen', 'NPS') AND result NOT LIKE '%No parasi%'
              AND status_id IN (4, 5) AND result IS NOT NULL THEN test_id
            END)
          RUBY
        end

        def calculate_positive_malaria_slides_in_5_yrs
          <<-RUBY
            COUNT(DISTINCT CASE
              WHEN test_type IN ('Malaria Screening', 'Malaria Screening (Paeds)', 'Malaria Blood Film') 
              AND test_indicator_name IN ('Blood film', 'Results','Malaria Species') AND ((created_date - dob) > 5) 
              AND result NOT IN ('NMPS', 'Negative', 'no malaria palasite seen', 'No malaria parasites seen', 
                'No tryps seen', 'No parasite seen', 'NPS') AND result NOT LIKE '%No parasi%'
              AND status_id IN (4, 5) AND result IS NOT NULL THEN test_id
            END)
          RUBY
        end

        def calculate_malaria_microscopy_in_unknown_age
          <<-RUBY
            COUNT(DISTINCT CASE
              WHEN test_type IN ('Malaria Screening', 'Malaria Screening (Paeds)', 'Malaria Blood Film') 
              AND test_indicator_name IN ('Blood film', 'Results','Malaria Species') AND dob IS NULL AND status_id IN (4, 5) AND result IS NOT NULL THEN test_id
            END)
          RUBY
        end

        def calculate_positive_malaria_slides_in_unknown_age
          <<-RUBY
            COUNT(DISTINCT CASE
              WHEN test_type IN ('Malaria Screening', 'Malaria Screening (Paeds)', 'Malaria Blood Film') 
              AND test_indicator_name IN ('Blood film', 'Results','Malaria Species') AND dob IS NULL
              AND result NOT IN ('NMPS', 'Negative', 'no malaria palasite seen', 'No malaria parasites seen', 
                'No tryps seen', 'No parasite seen', 'NPS') AND result NOT LIKE '%No parasi%'
              AND status_id IN (4, 5) AND result IS NOT NULL THEN test_id
            END)
          RUBY
        end

        def calculate_total_mrdts_done
          <<-RUBY
            COUNT(DISTINCT CASE
              WHEN test_type IN ('Malaria Screening', 'Malaria Screening (Paeds)', 'MRDT ..', 'MRDT')
              AND test_indicator_name = 'MRDT' AND status_id IN (4, 5) AND result IS NOT NULL THEN test_id
            END)
          RUBY
        end

        def calculate_mrdts_positives
          <<-RUBY
            COUNT(DISTINCT CASE
              WHEN test_type IN ('Malaria Screening', 'Malaria Screening (Paeds)', 'MRDT ..', 'MRDT')
              AND test_indicator_name = 'MRDT' AND result = 'Positive' AND status_id IN (4, 5) AND result IS NOT NULL THEN test_id
            END)
          RUBY
        end

        def calculate_mrdts_in_5yrs
          <<-RUBY
            COUNT(DISTINCT CASE
              WHEN test_type IN ('Malaria Screening', 'Malaria Screening (Paeds)', 'MRDT ..', 'MRDT')
              AND test_indicator_name = 'MRDT' AND ((created_date - dob) <= 5) AND status_id IN (4, 5) AND result IS NOT NULL THEN test_id
            END)
          RUBY
        end

        def calculate_mrdt_positives_in_5yrs
          <<-RUBY
            COUNT(DISTINCT CASE
              WHEN test_type IN ('Malaria Screening', 'Malaria Screening (Paeds)', 'MRDT ..', 'MRDT')
              AND test_indicator_name = 'MRDT' AND ((created_date - dob) <= 5) AND result = 'Positive' AND status_id IN (4, 5) AND result IS NOT NULL THEN test_id
            END)
          RUBY
        end

        def calculate_mrdts_in_5_yrs
          <<-RUBY
            COUNT(DISTINCT CASE
              WHEN test_type IN ('Malaria Screening', 'Malaria Screening (Paeds)', 'MRDT ..', 'MRDT')
              AND test_indicator_name = 'MRDT' AND ((created_date - dob) > 5) AND status_id IN (4, 5) AND result IS NOT NULL THEN test_id
            END)
          RUBY
        end

        def calculate_mrdt_positives_in_5_yrs
          <<-RUBY
            COUNT(DISTINCT CASE
              WHEN test_type IN ('Malaria Screening', 'Malaria Screening (Paeds)', 'MRDT ..', 'MRDT')
              AND test_indicator_name = 'MRDT' AND ((created_date - dob) > 5) AND result = 'Positive' AND status_id IN (4, 5) AND result IS NOT NULL THEN test_id
            END)
          RUBY
        end

        def calculate_total_invalid_mrdts_tests
          <<-RUBY
            COUNT(DISTINCT CASE
              WHEN test_type IN ('Malaria Screening', 'Malaria Screening (Paeds)', 'MRDT ..', 'MRDT')
              AND test_indicator_name = 'MRDT' AND result = 'Invalid' AND status_id IN (4, 5) AND result IS NOT NULL THEN test_id
            END)
          RUBY
        end

        def calculate_trypanosome_tests
          <<-RUBY
            COUNT(DISTINCT CASE
              WHEN test_type IN ('Trypanosome tests', 'TRYPANOSOMIASIS') AND status_id IN (4, 5) AND result IS NOT NULL THEN test_id
            END)
          RUBY
        end

        def calculate_positive_tests
          <<-RUBY
            COUNT(DISTINCT CASE
              WHEN test_type IN ('Trypanosome tests', 'TRYPANOSOMIASIS') AND result IN ('Positive', 'Seen') AND status_id IN (4, 5) AND result IS NOT NULL THEN test_id
            END)
          RUBY
        end

        def calculate_urine_microscopy_total
          <<-RUBY
            COUNT(DISTINCT CASE
              WHEN test_type IN ('Urine Microscopy', 'Urine Microscopy (Paeds)') AND status_id IN (4, 5) AND result IS NOT NULL THEN test_id
            END)
          RUBY
        end

        def calculate_schistosome_haematobium
          <<-RUBY
            COUNT(DISTINCT CASE
              WHEN test_type IN ('Schistosome Haematobiums', 'Schistosome Haematobium') AND status_id IN (4, 5) AND result IS NOT NULL THEN test_id
            END)
          RUBY
        end

        def calculate_other_urine_parasites
          <<-RUBY
            COUNT(DISTINCT CASE
              WHEN test_type = 'Other urine parasites' AND status_id IN (4, 5) AND result IS NOT NULL THEN test_id
            END)
          RUBY
        end

        def calculate_urine_chemistry_count
          <<-RUBY
            COUNT(DISTINCT CASE
              WHEN test_type IN ('Urine Chemistries', 'Urine chemistry (paeds)') AND status_id IN (4, 5) AND result IS NOT NULL THEN test_id
            END)
          RUBY
        end

        def calculate_semen_analysis_count
          <<-RUBY
            COUNT(DISTINCT CASE
              WHEN test_type = 'Semen Analysis' AND status_id IN (4, 5) AND result IS NOT NULL THEN test_id
            END)
          RUBY
        end

        def calculate_blood_parasites_count
          <<-RUBY
            COUNT(DISTINCT CASE
              WHEN test_type = 'Blood Parasites Screen' AND status_id IN (4, 5) AND result IS NOT NULL THEN test_id
            END)
          RUBY
        end

        def calculate_blood_parasites_seen
          <<-RUBY
            COUNT(DISTINCT CASE
              WHEN test_type = 'Blood Parasites Screen' AND result NOT LIKE  '%no%'
              AND result NOT IN ('NMPS', 'NPS') AND status_id IN (4, 5) AND result IS NOT NULL THEN test_id
            END)
          RUBY
        end

        def calculate_stool_microscopy_count
          <<-RUBY
            COUNT(DISTINCT CASE
              WHEN test_type IN ('Stool Analysis', 'Stool Analysis (Paeds)') AND test_indicator_name = 'Microscopy'
              AND status_id IN (4, 5) AND result IS NOT NULL THEN test_id
            END)
          RUBY
        end

        def calculate_stool_microscopy_parasites_seen
          <<-RUBY
            COUNT(DISTINCT CASE
              WHEN test_type IN ('Stool Analysis', 'Stool Analysis (Paeds)') AND test_indicator_name = 'Microscopy'
              AND NOT EXISTS (SELECT 1
                FROM (SELECT 'No ova' AS results UNION
                      SELECT 'No Para' UNION
                      SELECT 'No  Para' UNION
                      SELECT 'Not Seen' UNION
                      SELECT 'No cyst' UNION
                      SELECT 'NO Orga' UNION
                      SELECT 'Nothing' UNION
                      SELECT 'No tro' UNION
                      SELECT 'No cells' UNION
                      SELECT 'No pala') exclude_results
                WHERE result LIKE CONCAT('%', exclude_results.results, '%'))
              AND status_id IN (4, 5) AND result IS NOT NULL THEN test_id
            END)
          RUBY
        end
      end
    end
  end
end
