# frozen_string_literal: true

client_identifier_types = %w[current_village current_district current_traditional_authority physical_address phone npid]
client_identifier_types.each do |client_identifier_type|
  puts "Creating #{client_identifier_type} client identifier type"
  ClientIdentifierType.find_or_create_by(name: client_identifier_type)
end

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

stock_adjustment_reasons = %w[Damaged Expired Lost Theft Other Misplace_stock Incorrect_entry Phased_out Banned Missing Transfer_to_another_facility For_trainings]
stock_adjustment_reasons.each do |reason|
  puts "Creating stock adjustment reason: #{reason}"
  StockAdjustmentReason.find_or_create_by!(name: reason.gsub('_', ' '))
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
    manual_names: ['Labour', 'Labour Ward', 'EM LW', 'Maternity', 'PNW', '2A', '2B', '3A', '3B', 'LW', 'Maternity Ward',
                   'Antinatal', 'Postnatal Ward']
  },
  {
    actual_name: 'paeds',
    manual_names: ['CWA', 'CWB', 'CWC', 'EM Nursery', 'Under 5 Clinic', 'ward 9', 'Paediatric Ward', 'Paeds Neuro',
                   'Nursery', 'Paediatric', 'Peads Special Care Ward', 'Paeds Medical', 'Peads Isolation Centre',
                   'Paediatric Surgical', 'Paediatric Medical', 'Paeds Orthopedic',
                   'Children\'s ward', 'Peads Moyo', 'Peads Nursery', 'Peads Oncology', 'Peads Orthopeadics',
                   'Peads Surgical Ward', 'Mercy James Paediatric Centre', 'Peads']
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
    manual_names: ['ALPU', 'ALP', 'Alkaline Phosphate(ALP)', 'Alkaline Phosphatase']
  },
  {
    actual_name: 'ALT',
    manual_names: ['ALT/GPT', 'ALT', 'GPT/ALT', 'Alanine-Aminotransferase']
  },
  {
    actual_name: 'AST',
    manual_names: ['AST/GOT', 'AST', 'GOT/AST', 'Aspartate-Aminotransferase']
  },
  {
    actual_name: 'GGT',
    manual_names: ['GGT/r-GT', 'GGT', 'GGT/a-GT', 'Gamma-Glutamyltransferase']
  },
  {
    actual_name: 'BIT',
    manual_names: ['Bilirubin Total(BIT))', 'Bilirubin Total(BIT)', 'TBIL-DSA', 'TBIL-DSA-H',
                   'Bilirubin Total(TBIL-DSA))', 'Total Bilirubin (T-BIL-V)', 'Total Bilirubin']
  },
  {
    actual_name: 'BID',
    manual_names: ['Bilirubin Direct(BID)', 'DBIL-DSA', 'DBIL-DSA-H', 'Bilirubin Direct(DBIL-DSA)',
                   'Direct Bilirubin (D-BIL-V)', 'Direct Bilirubin']
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
                   'Maternity Ward', 'Antenatal', 'ANC', 'Antinatal']
  },
  {
    actual_name: 'Hepatitis B',
    manual_names: ['Hepatitis B Test', 'Hepatitis B test (Paeds)', 'Hepatitis B test(CancerCenter)', 'Hepatitis B']
  },
  {
    actual_name: 'Hepatitis C',
    manual_names: ['Hepatitis C Test', 'Hepatitis C test (Paeds)', 'Hepatitis C', 'Hepatitis C test(CancerCenter)',
                   'Hep C']
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
    manual_names: ['TB Tests', 'TB Microscopy', 'TB', 'TB_Microscopy', 'TB Gene_Xpert', 'TB Microscopic Exam']
  },
  {
    actual_name: 'TB LAM',
    manual_names: ['TB LAM', 'Urine Lam']
  },
  {
    actual_name: 'GeneXpert Tests',
    manual_names: ['GENE-XPERT TB Tests', 'TB Gene_Xpert']
  },
  {
    actual_name: 'GeneXpert MTB',
    manual_names: ['Gene Xpert MTB']
  },
  {
    actual_name: 'GeneXpert RIF',
    manual_names: ['Gene Xpert RIF Resistance']
  },
  {
    actual_name: 'Smear Microscopy',
    manual_names: ['Smear microscopy result', 'Smear microscopy result 1', 'TB Microscopy Sample 1',
                   'TB Microscopy Sample 2']
  },
  {
    actual_name: 'Malaria',
    manual_names: ['Malaria Screening', 'Malaria Screening (Paeds)', 'Malaria Blood Film', 'MRDT', 'MRDT ..',
                   'Malaria Rapid Diagnostic Test', 'Malaria Microscopy']
  },
  {
    actual_name: 'Malaria Indicators',
    manual_names: ['Blood film', 'Results', 'Malaria Species', 'Parasite', 'Malaria Parasite Density']
  },
  {
    actual_name: 'Trypanosome',
    manual_names: ['Trypanosome tests', 'TRYPANOSOMIASIS']
  },
  {
    actual_name: 'Urine Chemistries',
    manual_names: [
      'Blood',
      'Urobilinogen',
      'Bilirubin',
      'Protein',
      'Nitrate',
      'Ketones',
      'Glucose',
      'Specific gravity'
    ]
  },
  {
    actual_name: 'Semen Analysis',
    manual_names: [
      'Appearance',
      'Liquifaction time',
      'volume',
      'pH',
      'Sperm count',
      'Sperm morphology',
      'Progressive motility',
      'Non-progressive motility',
      'Immotility'
    ]
  },
  {
    actual_name: 'Trypanosome',
    manual_names: ['Trypanosome tests', 'TRYPANOSOMIASIS']
  },
  {
    actual_name: 'COVID',
    manual_names: ['SARS COV 19', 'SARS Cov 2', 'SARS-CoV-2', 'SARS COV-2 Rapid Antigen']
  },
  {
    actual_name: 'Cuture & Sensitivity',
    manual_names: ['Culture & Sensitivity', 'Culture & Sensitivity (Paeds)', 'Culture/sensistivity', 'Blood Culture']
  },
  {
    actual_name: 'Cholera',
    manual_names: ['Cholera', 'Vibrio cholerae', 'cholera rapid test', 'cholera rapoid test', 'Cholera RDT',
                   'Rapid Test', 'cholera test', 'Vibrio cholerae Non 01', 'Vibrio cholerae 01 (Ogawa)',
                   'Vibrio cholerae 01 (Inaba)']
  },
  {
    actual_name: 'India Ink',
    manual_names: ['India Ink', 'India Ink (Paeds)']
  },
  {
    actual_name: 'Gram Stain',
    manual_names: ['Gram Stain', 'Gram Stain (Paeds)']
  },
  {
    actual_name: 'Urine Chemistry',
    manual_names: ['Urine Chemistries', 'Urine chemistry (paeds)']
  },
  {
    actual_name: 'Cryptococcus Antigen Test',
    manual_names: ['Cryptococcus Antigen Test', 'Cryptococcus Antigen Test (Paeds)', 'Cryptococcal Antigen Test',
                   'CrAg']
  }
]

name_mappings.each do |name_mapping|
  name_mapping[:manual_names].each do |manual_name|
    puts "Creating name mapping for #{manual_name} - #{name_mapping[:actual_name]}"
    NameMapping.find_or_create_by(actual_name: name_mapping[:actual_name], manual_name:)
  end
end

male_tests = ['Semen Analysis']
male_tests.each do |name|
  puts "Updating sex for #{name}"
  TestType.where(name:).update_all(sex: 'Male')
end

female_tests = ['Pregnancy Test', 'Chronic Gonatropin', 'HVS analysis', 'Prolactin', 'Wet prep']
female_tests.each do |name|
  puts "Updating sex for #{name}"
  TestType.where(name:).update_all(sex: 'Female')
end

settings = [
  {
    name: 'use_elasticsearch',
    value: 'true'
  },
  {
    name: 'default_accession_number_length',
    value: '10'
  }
]
settings.each do |setting|
  puts "Creating setting #{setting[:name]}"
  next if setting[:name].blank? || setting[:value].blank?
  next if AppSetting.where(name: setting[:name]).exists?

  set = AppSetting.find_or_create_by(name: setting[:name])
  set.update(value: setting[:value])
end
