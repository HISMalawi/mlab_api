# frozen_string_literal: true

# reports module
module Reports
  # Moh reports module
  module Moh
    # Helper module for calculating indicator counts
    module MigrationHelpers
      # Calculate the counts Biochemistry indicators
      module BiochemistryIndicatorCalculations
        def calculate_blood_glucose
          <<-RUBY
            COUNT(DISTINCT CASE
              WHEN test_type IN ('Glucose', 'Glucose (Paeds)') AND status_id IN (4, 5) AND result IS NOT NULL
              AND specimen = 'Blood' AND test_indicator_name IN ('Glucose', 'Glu','Glu-G')
              THEN test_id
            END)
          RUBY
        end

        def calculate_csf_glucose
          <<-RUBY
            COUNT(DISTINCT CASE
              WHEN test_type IN ('Glucose', 'Glucose (Paeds)') AND status_id IN (4, 5) AND result IS NOT NULL
              AND specimen = 'CSF' AND test_indicator_name IN ('Glucose', 'Glu','Glu-G')
              THEN test_id
            END)
          RUBY
        end

        def calculate_total_protein
          <<-RUBY
            COUNT(DISTINCT CASE
              WHEN test_type IN ('Liver Function Tests','Liver Function Tests (Paeds)') AND status_id IN (4, 5) AND result IS NOT NULL
              AND test_indicator_name IN ('Total Protein(PRO)', 'TP', 'Total Protein')
              THEN test_id
            END)
          RUBY
        end

        def calculate_albumin
          <<-RUBY
            COUNT(DISTINCT CASE
              WHEN test_type IN ('Liver Function Tests','Liver Function Tests (Paeds)') AND status_id IN (4, 5) AND result IS NOT NULL
              AND test_indicator_name IN ('Albumin(ALB)', 'ALB', 'Albumin') 
              THEN test_id
            END)
          RUBY
        end

        def calculate_alkaline_phosphatase_alp
          <<-RUBY
            COUNT(DISTINCT CASE
              WHEN test_type IN ('Liver Function Tests','Liver Function Tests (Paeds)') AND status_id IN (4, 5) AND result IS NOT NULL
              AND test_indicator_name IN ('ALPU', 'ALP', 'Alkaline Phosphate(ALP)') 
              THEN test_id
            END)
          RUBY
        end

        def calculate_alanine_aminotransferase_alt
          <<-RUBY
            COUNT(DISTINCT CASE
              WHEN test_type IN ('Liver Function Tests','Liver Function Tests (Paeds)') AND status_id IN (4, 5) AND result IS NOT NULL
              AND test_indicator_name IN ('ALT/GPT', 'ALT','GPT/ALT') 
              THEN test_id
            END)
          RUBY
        end

        def calculate_amylase
          <<-RUBY
            COUNT(DISTINCT CASE
              WHEN test_type = 'Pancreatic Function Test' AND status_id IN (4, 5) AND result IS NOT NULL
              AND test_indicator_name = 'Amylase'
              THEN test_id
            END)
          RUBY
        end

        def calculate_antistreptolysin_o_aso
          <<-RUBY
            COUNT(DISTINCT CASE
              WHEN test_type IN ('Anti Streptolysis O', 'BioMarkers','Anti Streptolysin O') AND status_id IN (4, 5) AND result IS NOT NULL
              AND test_indicator_name IN ('ASO', 'Anti Streptolysis O', 'Antistreptolysin O (ASO)')
              THEN test_id
            END)
          RUBY
        end

        def calculate_aspartate_aminotransferase_ast
          <<-RUBY
            COUNT(DISTINCT CASE
              WHEN test_type IN ('Liver Function Tests','Liver Function Tests (Paeds)') AND status_id IN (4, 5) AND result IS NOT NULL
              AND test_indicator_name IN ('AST/GOT', 'AST', 'GOT/AST')
              THEN test_id
            END)
          RUBY
        end

        def calculate_gamma_glutamyl_transferase
          <<-RUBY
            COUNT(DISTINCT CASE
              WHEN test_type IN ('Liver Function Tests','Liver Function Tests (Paeds)') AND status_id IN (4, 5) AND result IS NOT NULL
              AND test_indicator_name IN ('GGT/r-GT', 'GGT','GGT/a-GT') 
              THEN test_id
            END)
          RUBY
        end

        def calculate_bilirubin_total
          <<-RUBY
            COUNT(DISTINCT CASE
              WHEN test_type IN ('Liver Function Tests','Liver Function Tests (Paeds)') AND status_id IN (4, 5) AND result IS NOT NULL
              AND test_indicator_name IN ('Bilirubin Total(BIT))', 'Bilirubin Total(BIT)', 'TBIL-DSA','TBIL-DSA-H', 'Bilirubin Total(TBIL-DSA))','Total Bilirubin (T-BIL-V)') 
              THEN test_id
            END)
          RUBY
        end

        def calculate_bilirubin_direct
          <<-RUBY
            COUNT(DISTINCT CASE
              WHEN test_type IN ('Liver Function Tests','Liver Function Tests (Paeds)') AND status_id IN (4, 5) AND result IS NOT NULL
              AND test_indicator_name IN ('Bilirubin Direct(BID)', 'DBIL-DSA','DBIL-DSA-H','Bilirubin Direct(DBIL-DSA)', 'Direct Bilirubin (D-BIL-V)') 
              THEN test_id
            END)
          RUBY
        end

        def calculate_calcium
          <<-RUBY
            COUNT(DISTINCT CASE
              WHEN test_type IN ('Minerals', 'Calcium', 'Minerals (Paeds)', 'Electrolytes') AND status_id IN (4, 5) AND result IS NOT NULL
              AND test_indicator_name IN ('Calcium (CA)', 'Calcium', 'Ca', 'CA')  
              THEN test_id
            END)
          RUBY
        end

        def calculate_chloride
          <<-RUBY
            COUNT(DISTINCT CASE
              WHEN test_type IN ('Minerals', 'Calcium', 'Minerals (Paeds)', 'Electrolytes') AND status_id IN (4, 5) AND result IS NOT NULL
              AND test_indicator_name IN ('Chloride (Cl-)', 'Chloride', 'Cl')
              THEN test_id
            END)
          RUBY
        end

        def calculate_cholesterol_total
          <<-RUBY
            COUNT(DISTINCT CASE
              WHEN test_type IN ('Lipogram', 'Lipogram (Paeds)') AND status_id IN (4, 5) AND result IS NOT NULL
              AND test_indicator_name IN ('Cholestero l(CHOL)', 'Total Cholesterol(CHOL)', 'TC') 
              THEN test_id
            END)
          RUBY
        end

        def calculate_cholesterol_ldl
          <<-RUBY
            COUNT(DISTINCT CASE
              WHEN test_type IN ('Lipogram', 'Lipogram (Paeds)') AND status_id IN (4, 5) AND result IS NOT NULL
              AND test_indicator_name IN ('LDL Direct (LDL-C)', 'LDL-C') 
              THEN test_id
            END)
          RUBY
        end

        def calculate_cholesterol_hdl
          <<-RUBY
            COUNT(DISTINCT CASE
              WHEN test_type IN ('Lipogram', 'Lipogram (Paeds)') AND status_id IN (4, 5) AND result IS NOT NULL
              AND test_indicator_name IN ('HDL Direct (HDL-C)', 'HDL-C')
              THEN test_id
            END)
          RUBY
        end

        def calculate_cholinesterase
          <<-RUBY
            COUNT(DISTINCT CASE
              WHEN test_type  = 'Cholinesterase' AND status_id IN (4, 5) AND result IS NOT NULL
              THEN test_id
            END)
          RUBY
        end

        def calculate_c_reactive_protein_crp
          <<-RUBY
            COUNT(DISTINCT CASE
              WHEN test_type IN ('C-reactive protein', 'BioMarkers') AND status_id IN (4, 5) AND result IS NOT NULL
              AND test_indicator_name IN ('C-reactive Protein (CRP)', 'C-reactive Protein', 'CRP')
              THEN test_id
            END)
          RUBY
        end

        def calculate_creatinine
          <<-RUBY
            COUNT(DISTINCT CASE
              WHEN test_type IN ('Renal Function Test','Renal Function Tests (Paeds)') AND status_id IN (4, 5) AND result IS NOT NULL
              AND test_indicator_name IN ('Creatinine', 'CREA-S', 'CREATININE (S)')
              THEN test_id
            END)
          RUBY
        end

        def calculate_creatine_kinase_nac
          <<-RUBY
            COUNT(DISTINCT CASE
              WHEN test_type = 'Cardiac Function Tests' AND status_id IN (4, 5) AND result IS NOT NULL
              AND test_indicator_name = 'Creatine Kinase(CKN)'
              THEN test_id
            END)
          RUBY
        end

        def calculate_creatine_kinase_mb
          <<-RUBY
            COUNT(DISTINCT CASE
              WHEN test_type = 'Cardiac Function Tests' AND status_id IN (4, 5) AND result IS NOT NULL
              AND test_indicator_name = 'Creatine Kinase MB(CKMB)' 
              THEN test_id
            END)
          RUBY
        end

        def calculate_haemoglobin_a1c
          <<-RUBY
            COUNT(DISTINCT CASE
              WHEN status_id IN (4, 5) AND result IS NOT NULL
              AND test_indicator_name IN ('HbA1c','HbA1c (Paeds)') 
              THEN test_id
            END)
          RUBY
        end

        def calculate_iron
          <<-RUBY
            COUNT(DISTINCT CASE
              WHEN test_type IN ('Iron Studies', 'Iron') AND status_id IN (4, 5) AND result IS NOT NULL
              AND test_indicator_name IN ('Iron', 'Fe')  
              THEN test_id
            END)
          RUBY
        end

        def calculate_lipase
          <<-RUBY
            COUNT(DISTINCT CASE
              WHEN test_type IN ('Pancreatic Function Test', 'Lipase','Lipogram') AND status_id IN (4, 5) AND result IS NOT NULL
              AND test_indicator_name = 'Lipase'
              THEN test_id
            END)
          RUBY
        end

        def calculate_lactate_dehydrogenase_ldh
          <<-RUBY
            COUNT(DISTINCT CASE
              WHEN test_type IN ('Cardiac Function Tests', 'Lactate Dehydrogenase') AND status_id IN (4, 5) AND result IS NOT NULL
              AND test_indicator_name IN ('Lactatedehydrogenase(LDH)', 'LDH')
              THEN test_id
            END)
          RUBY
        end

        def calculate_magnesium
          <<-RUBY
            COUNT(DISTINCT CASE
              WHEN test_type IN ('Minerals', 'Magnesium', 'Minerals (Paeds)','Electrolytes') AND status_id IN (4, 5) AND result IS NOT NULL
              AND test_indicator_name IN ('Magnesium (MGXB)', 'Mg', 'Magnesium', 'MG') 
              THEN test_id
            END)
          RUBY
        end

        def calculate_phosphorus
          <<-RUBY
            COUNT(DISTINCT CASE
              WHEN test_type IN ('Minerals', 'Phosphorus', 'Minerals (Paeds)', 'Electrolytes') AND status_id IN (4, 5) AND result IS NOT NULL
              AND test_indicator_name IN ('Phosphorus (PHOS)', 'P', 'Phosphorus', 'PHO') 
              THEN test_id
            END)
          RUBY
        end

        def calculate_potassium
          <<-RUBY
            COUNT(DISTINCT CASE
              WHEN test_type IN ('Minerals', 'Potassium', 'Electrolytes', 'Minerals (Paeds)', 'Electrolytes (Paeds)') AND status_id IN (4, 5) AND result IS NOT NULL
              AND test_indicator_name IN ('Potassium (K)', 'K', 'Potassium') 
              THEN test_id
            END)
          RUBY
        end

        def calculate_rheumatoid_factor
          <<-RUBY
            COUNT(DISTINCT CASE
              WHEN test_type IN ('Rheumatoid Factor Test', 'BioMarkers') AND status_id IN (4, 5) AND result IS NOT NULL
              AND test_indicator_name IN ('Rheumatoid Factor Test', 'Rheumatoid Factor (RF)', 'Rheumatoid Factor', 'RF')
              THEN test_id
            END)
          RUBY
        end

        def calculate_sodium
          <<-RUBY
            COUNT(DISTINCT CASE
              WHEN test_type IN ('Minerals', 'Sodium', 'Electrolytes', 'Minerals (Paeds)', 'Electrolytes (Paeds)') AND status_id IN (4, 5) AND result IS NOT NULL
              AND test_indicator_name IN ('Sodium (NA)', 'Na', 'Sodium')
              THEN test_id
            END)
          RUBY
        end

        def calculate_triglycerides
          <<-RUBY
            COUNT(DISTINCT CASE
              WHEN test_type IN ('Lipogram','Lipogram (Paeds)') AND status_id IN (4, 5) AND result IS NOT NULL
              AND test_indicator_name IN ('Triglycerides(TG)', 'TG')
              THEN test_id
            END)
          RUBY
        end

        def calculate_urea
          <<-RUBY
            COUNT(DISTINCT CASE
              WHEN test_type IN ('Renal Function Test', 'Renal Function Tests (Paeds)') AND status_id IN (4, 5) AND result IS NOT NULL
              AND test_indicator_name IN ('Urea','Urea/Bun')
              THEN test_id
            END)
          RUBY
        end

        def calculate_uric_acid
          <<-RUBY
            COUNT(DISTINCT CASE
              WHEN test_type IN ('Uric Acid','Renal Function Test') AND status_id IN (4, 5) AND result IS NOT NULL
              AND test_indicator_name IN ('UA', 'UASR')
              THEN test_id
            END)
          RUBY
        end

        def calculate_micro_protein
          <<-RUBY
            COUNT(DISTINCT CASE
              WHEN test_type  = 'Microprotein' AND status_id IN (4, 5) AND result IS NOT NULL
              THEN test_id
            END)
          RUBY
        end

        def calculate_micro_albumin
          <<-RUBY
            COUNT(DISTINCT CASE
              WHEN test_type  = 'Microalbumin' AND status_id IN (4, 5) AND result IS NOT NULL
              THEN test_id
            END)
          RUBY
        end
      end
    end
  end
end
