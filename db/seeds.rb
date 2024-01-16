# frozen_string_literal: true

stock_statuses = ['Draft', 'Pending', 'Requested', 'Received', 'Approved', 'Rejected', 'Not collected']
stock_statuses.each do |status|
  puts "Creating stock status: #{status}"
  StockStatus.find_or_create_by!(
    name: status
  )
end

stock_transaction_types = ['In', 'Out', 'Reverse Issue Out Due To Rejection', 'Adjust Stock']
stock_transaction_types.each do |type|
  puts "Creating stock transaction type: #{type}"
  StockTransactionType.find_or_create_by!(
    name: type
  )
end

stock_adjustment_reasons = %w[Damaged Expired Lost Theft Other]
stock_adjustment_reasons.each do |reason|
  puts "Creating stock adjustment reason: #{reason}"
  StockAdjustmentReason.find_or_create_by!(name: reason)
end

name_mappings = [
  {
    actual_name: 'FBC',
    manual_names: ['FBC', 'FBC (Paeds)', 'FBC(CancerCenter)']
  },
  {
    actual_name: 'Haemoglobin',
    manual_names: %w[Haemoglobin HGB Hb Hemoglobin Heamoglobin Haemoglobin(CancerCenter)]
  },
  {
    actual_name: 'Cross-match',
    manual_names: ['Cross-match', 'Cross-match(CancerCenter)']
  },
  {
    actual_name: 'Pack ABO Group',
    manual_names: ['Pack ABO Group']
  },
  {
    actual_name: 'ESR',
    manual_names: ['ESR', 'ESR (Paeds)', 'ESR (CancerCenter)']
  },
  {
    actual_name: 'Manual Differential & Cell Morphology',
    manual_names: ['Manual Differential & Cell Morphology', 'Manual Differential & Cell Morphology(CancerCenter)']
  },
  {
    actual_name: 'Maternity',
    manual_names: ['Labour', 'Labour Ward', 'EM LW', 'Maternity', 'PNW', '2A', '2B', '3A', '3B', 'LW', 'Maternity Ward']
  },
  {
    actual_name: 'paeds',
    manual_names: ['CWA', 'CWB', 'CWC', 'EM Nursery', 'Under 5 Clinic', 'ward 9', 'Paediatric Ward', 'Paeds Neuro',
                   'Nursery', 'Paediatric', 'Peads Special Care Ward', 'Paeds Medical', 'Peads Isolation Centre',
                   'Paediatric Surgical', 'Paediatric Medical', 'Paeds Orthopedic',
                   'Children\'s ward', 'Peads Moyo', 'Peads Nursery', 'Peads Oncology', 'Peads Orthopeadics',
                   'Peads Surgical Ward', 'Mercy James Paediatric Centre']
  },
  {
    actual_name: 'Pack ABO Group',
    manual_names: ['Pack ABO Group']
  },
  {
    actual_name: 'Glucose',
    manual_names: ['Glucose', 'Glucose (Paeds)']
  },
  {
    actual_name: 'Total Protein',
    manual_names: ['Total Protein(PRO)', 'TP', 'Total Protein']
  },
  {
    actual_name: 'Albumin',
    manual_names: ['Albumin(ALB)', 'ALB', 'Albumin']
  },
  {
    actual_name: 'ALP',
    manual_names: ['ALPU', 'ALP', 'Alkaline Phosphate(ALP)']
  },
  {
    actual_name: 'ALT',
    manual_names: ['ALT/GPT', 'ALT', 'GPT/ALT']
  },
  {
    actual_name: 'AST',
    manual_names: ['AST/GOT', 'AST', 'GOT/AST']
  },
  {
    actual_name: 'GGT',
    manual_names: ['GGT/r-GT', 'GGT', 'GGT/a-GT']
  },
  {
    actual_name: 'BIT',
    manual_names: ['Bilirubin Total(BIT))', 'Bilirubin Total(BIT)', 'TBIL-DSA', 'TBIL-DSA-H',
                   'Bilirubin Total(TBIL-DSA))', 'Total Bilirubin (T-BIL-V)']
  },
  {
    actual_name: 'BID',
    manual_names: ['Bilirubin Direct(BID)', 'DBIL-DSA', 'DBIL-DSA-H', 'Bilirubin Direct(DBIL-DSA)',
                   'Direct Bilirubin (D-BIL-V)']
  },
  {
    actual_name: 'LFT',
    manual_names: ['Liver Function Tests', 'Liver Function Tests (Paeds)', 'Liver Function Tests(CancerCenter)',
                   'Liver Function Test']
  },
  {
    actual_name: 'RFT',
    manual_names: ['Renal Function Test', 'Renal Function Tests (Paeds)', 'Renal Function Tests(CancerCenter)']
  },
  {
    actual_name: 'Electrolytes',
    manual_names: ['Electrolytes', 'Electrolytes (Paeds)', 'Electrolytes(CancerCenter)']
  },
  {
    actual_name: 'Minerals',
    manual_names: ['Minerals', 'Minerals (Paeds)', 'Minerals(CancerCenter)']
  },
  {
    actual_name: 'ASO',
    manual_names: ['Anti Streptolysis O', 'Anti Streptolysin O', 'Antistreptolysin O (ASO)', 'ASO']
  },
  {
    actual_name: 'Glucose',
    manual_names: %w[Glucose Glu Glu-G]
  },
  {
    actual_name: 'Syphilis Test',
    manual_names: ['Syphilis Test', 'Syphilis Test (Paeds)']
  },
  {
    actual_name: 'Antenatal',
    manual_names: ['EM THEATRE', 'Labour', 'Labour Ward', 'EM LW', 'Maternity', 'PNW', '2A', '2B', '3A', '3B', 'LW',
                   'Maternity Ward', 'Antenatal', 'ANC']
  },
  {
    actual_name: 'Hepatitis',
    manual_names: ['Hepatitis B Test', 'Hepatitis B test (Paeds)', 'Hepatitis B test(CancerCenter)']
  },
  {
    actual_name: 'Hepatitis C',
    manual_names: ['Hepatitis C Test', 'Hepatitis C test (Paeds)', 'Hepatitis C', 'Hepatitis C test(CancerCenter)']
  },
  {
    actual_name: 'HIV',
    manual_names: ['HIV', 'HIV TEST', 'HIV Antibody Tests']
  },
  {
    actual_name: 'Prostate Ag Test',
    manual_names: ['PSA', 'Prostate Specific Antigens', 'Total Prostrate Specific Antigen',
                   'Free Prostrate Specific Antigen']
  },
  {
    actual_name: 'Calcium',
    manual_names: ['Calcium (CA)', 'Calcium', 'Ca', 'CA']
  },
  {
    actual_name: 'Chloride',
    manual_names: ['Chloride (Cl-)', 'Chloride', 'Cl']
  },
  {
    actual_name: 'Lipogram',
    manual_names: ['Lipogram', 'Lipogram (Paeds)', 'Lipogram(CancerCenter)']
  },
  {
    actual_name: 'TC',
    manual_names: ['Cholestero l(CHOL)', 'Total Cholesterol(CHOL)', 'TC']
  },
  {
    actual_name: 'LDL',
    manual_names: ['LDL Direct (LDL-C)', 'LDL-C']
  },
  {
    actual_name: 'HDL',
    manual_names: ['HDL Direct (HDL-C)', 'HDL-C']
  },
  {
    actual_name: 'Potassium',
    manual_names: ['Potassium (K)', 'K', 'Potassium']
  },
  {
    actual_name: 'Phosphorus',
    manual_names: ['Phosphorus (PHOS)', 'P', 'Phosphorus', 'PHO']
  },
  {
    actual_name: 'Magnesium',
    manual_names: ['Magnesium (MGXB)', 'Mg', 'Magnesium', 'MG']
  },
  {
    actual_name: 'Urea',
    manual_names: ['Urea', 'Urea/Bun']
  },
  {
    actual_name: 'Uric Acid',
    manual_names: ['UA', 'UASR', 'Uric Acid']
  },
  {
    actual_name: 'Triglycerides',
    manual_names: ['Triglycerides(TG)', 'TG']
  },
  {
    actual_name: 'Sodium',
    manual_names: ['Sodium (NA)', 'Na', 'Sodium']
  },
  {
    actual_name: 'Creatinine',
    manual_names: ['Creatinine', 'CREA-S', 'CREATININE (S)']
  },
  {
    actual_name: 'CRP',
    manual_names: ['C-reactive Protein (CRP)', 'C-reactive Protein', 'CRP']
  },
  {
    actual_name: 'LDH',
    manual_names: ['Lactatedehydrogenase(LDH)', 'LDH', 'Lactate Dehydrogenase']
  },
  {
    actual_name: 'Iron',
    manual_names: ['Iron Studies', 'Iron', 'Fe']
  },
  {
    actual_name: 'HbA1c',
    manual_names: ['HbA1c', 'HbA1c (Paeds)']
  },
  {
    actual_name: 'RF',
    manual_names: ['Rheumatoid Factor Test', 'Rheumatoid Factor (RF)', 'Rheumatoid Factor', 'RF',
                   'Rheumatoid Factor Test']
  },
  {
    actual_name: 'TB Tests',
    manual_names: ['TB Tests', 'TB Microscopy', 'TB', 'TB_Microscopy', 'TB Gene_Xpert']
  },
  {
    actual_name: 'TB LAM',
    manual_names: ['TB LAM', 'Urine Lam']
  },
  {
    actual_name: 'Smear Microscopy',
    manual_names: ['Smear microscopy result', 'Smear microscopy result 1']
  }
]

name_mappings.each do |name_mapping|
  name_mapping[:manual_names].each do |manual_name|
    puts "Creating name mapping for #{manual_name} - #{name_mapping[:actual_name]}"
    NameMapping.find_or_create_by(actual_name: name_mapping[:actual_name], manual_name:)
  end
end
