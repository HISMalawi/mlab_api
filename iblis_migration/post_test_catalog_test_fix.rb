# frozen_string_literal: true

specimen_types = [
  {
    current_name: 'Tissue fluid',
    test_catalog_name: 'Tissue',
    nlims_code: 'NLIMS_SP_0027_MWI'
  }
]

test_types = [
  {
    current_name: 'Human Chorionic Gonado Tropin',
    test_catalog_name: 'Beta Human Chorionic Gonatropin',
    nlims_code: 'NLIMS_TT_0095_MWI'
  },
  {
    current_name: 'hemoglobin',
    test_catalog_name: 'Haemoglobin',
    nlims_code: 'NLIMS_TT_0105_MWI'
  },
  {
    current_name: 'SLIT SKIN SMEAR',
    test_catalog_name: 'Skin Snips Analysis',
    nlims_code: 'NLIMS_TT_0317_MWI'
  },
  {
    current_name: 'Syphilis',
    test_catalog_name: 'Syphilis Test',
    nlims_code: 'NLIMS_TT_0019_MWI'
  },
  {
    current_name: 'MACROSCOPY',
    test_catalog_name: 'Urine Macroscopy',
    nlims_code: 'NLIMS_TT_0011_MWI'
  },
  {
    current_name: 'Hepatitis B virus',
    test_catalog_name: 'Hepatitis Virus B Viral Load',
    nlims_code: 'NLIMS_TT_0273_MWI'
  },
    {
    current_name: 'Crystal Rapid Diagnostic Test',
    test_catalog_name: 'Cholera Rapid Diagnostic Test',
    nlims_code: 'NLIMS_TT_0229_MWI'
  }
]

test_indicators = [
  {
    current_id: 467,
    current_name: 'Test Result',
    test_catalog_name: 'Beta Human Chorionic Gonatropin',
    nlims_code: 'NLIMS_TT_0095_MWI'
  },
  {
    current_id: 480,
    current_name: 'hemoglobin',
    test_catalog_name: 'Haemoglobin',
    nlims_code: 'NLIMS_TT_0105_MWI'
  },
  {
    current_id: 477,
    current_name: 'SSS RESULT',
    test_catalog_name: 'Microscopy Findings',
    nlims_code: 'NLIMS_TI_0821_MWI'
  },
  {
    current_id: 470,
    current_name: 'serology test',
    test_catalog_name: 'Venereal Disease Research Laboratory',
    nlims_code: 'NLIMS_TT_0127_MWI'
  },
   {
    current_id: 93,
    current_name: 'Macroscopy',
    test_catalog_name: 'Appearance',
    nlims_code: 'NLIMS_TT_0075_MWI'
  },
  {
    current_id: 469,
    current_name: 'reception test',
    test_catalog_name: 'Hepatitis B Virus Viral Load',
    nlims_code: 'NLIMS_TI_0694_MWI'
  },
  {
    current_id: 479,
    current_name: 'CRDT',
    test_catalog_name: 'Cholera RDT',
    nlims_code: 'NLIMS_TI_ 0586_MWI'
  }
]

ActiveRecord::Base.transaction do
  puts "Starting migration to resolve missing nlims codes..."
  puts "Updating specimen types, test types, and test indicators..."
  specimen_types.each do |specimen_type_attrs|
    puts "Mapping tests of specimen type: #{specimen_type_attrs[:current_name]} to #{specimen_type_attrs[:test_catalog_name]}"
    specimen_type = Specimen.find_by(name: specimen_type_attrs[:current_name])
    next if specimen_type.blank?

    test_catalog = Specimen.find_by(name: specimen_type_attrs[:test_catalog_name], nlims_code: specimen_type_attrs[:nlims_code])
    next if test_catalog.blank?

    Test.where(specimen_id: specimen_type.id).update_all(specimen_id: test_catalog.id)
  end

  test_types.each do |test_type_attrs|
    puts "Mapping tests of test type: #{test_type_attrs[:current_name]} to #{test_type_attrs[:test_catalog_name]}"
    test_type = TestType.find_by(name: test_type_attrs[:current_name])
    next if test_type.blank?

    test_catalog = TestType.find_by(name: test_type_attrs[:test_catalog_name], nlims_code: test_type_attrs[:nlims_code])
    next if test_catalog.blank?

    Test.where(test_type_id: test_type.id).update_all(test_type_id: test_catalog.id)
  end

  test_indicators.each do |test_indicator_attr|
    puts "Mapping test results of test indicator: #{test_indicator_attr[:current_name]} to #{test_indicator_attr[:test_catalog_name]}"
    test_indicator = TestIndicator.find_by(id: test_indicator_attr[:current_id], name: test_indicator_attr[:current_name])
    next if test_indicator.blank?

    test_catalog = TestIndicator.find_by(name: test_indicator_attr[:test_catalog_name], nlims_code: test_indicator_attr[:nlims_code])
    next if test_catalog.blank?

    TestResult.where(test_indicator_id: test_indicator.id).update_all(test_indicator_id: test_catalog.id)
  end
  puts "Migration to resolve missing nlims codes completed successfully"
end

# FIX/VOID Unsyc Order for bwaila: BWL2500000189 - Macroscopy test
order = Order.find_by(accession_number: 'BWL2500000189')
UnsyncOrder.where(data_level: 'order', test_or_order_id: order.id).update_all(sync_status: 1) if order.present?
