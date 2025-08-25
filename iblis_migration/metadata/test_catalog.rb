# Read a json file
test_catalog = JSON.parse(File.read('test_catalog_version.json'))

# Update specimens
specimens = test_catalog['catalog']['specimen_types']
specimens.each do |specimen|
  puts "Specimen ID: #{specimen['id']}, Name: #{specimen['name']}"
  specimen_type = Specimen.find_by(name: specimen['name'])
  specimen_type ||= Specimen.find_by(name: specimen['preferred_name'])
  specimen_type ||= Specimen.find_by(name: specimen['iblis_mapping_name'])
  if specimen_type
    specimen_type.update(
      name: specimen['name'],
      nlims_code: specimen['nlims_code'],
      preferred_name: specimen['preferred_name'],
      short_name: specimen['short_name']
    )
  else
    Specimen.create!(
      name: specimen['name'],
      nlims_code: specimen['nlims_code'],
      preferred_name: specimen['preferred_name'],
      short_name: specimen['short_name'],
      description: specimen['description'],
      scientific_name: specimen['scientific_name'],
      creator: User.first&.id
    )
  end
  puts "Processed Specimen: #{specimen['name']}"
end

specimen = Specimen.find_by(name: ' tissue biopsy')
specimen_bio = Specimen.find_by(name: 'Tissue Biopsies')
if specimen && specimen_bio
  puts "Updating Tests from #{specimen.name} to #{specimen_bio.name}"
  Test.where(specimen_id: specimen&.id).update_all(specimen_id: specimen_bio&.id)
  SpecimenTestTypeMapping.where(specimen_id: specimen&.id).update_all(specimen_id: specimen_bio&.id)
  specimen.destroy
end

specimen = Specimen.find_by(name: 'Nasolpharyngeal')
specimen_bio = Specimen.find_by(name: 'Nasopharyngeal swab')
if specimen && specimen_bio
  puts "Updating Tests from #{specimen.name} to #{specimen_bio.name}"
  Test.where(specimen_id: specimen&.id).update_all(specimen_id: specimen_bio&.id)
  SpecimenTestTypeMapping.where(specimen_id: specimen&.id).update_all(specimen_id: specimen_bio&.id)
  specimen.destroy
end

specimen = Specimen.find_by(name: 'Swab')
specimen_bio = Specimen.find_by(name: 'Swabs')
if specimen && specimen_bio
  puts "Updating Tests from #{specimen.name} to #{specimen_bio.name}"
  Test.where(specimen_id: specimen&.id).update_all(specimen_id: specimen_bio&.id)
  SpecimenTestTypeMapping.where(specimen_id: specimen&.id).update_all(specimen_id: specimen_bio&.id)
  specimen.destroy
end

# Update Drugs
drugs = test_catalog['catalog']['drugs']
drugs.each do |drug|
  puts "Drug ID: #{drug['id']}, Name: #{drug['name']}"
  drug_type = Drug.find_by(name: drug['name'])
  drug_type ||= Drug.find_by(name: drug['preferred_name'])
  drug_type ||= Drug.find_by(name: drug['iblis_mapping_name'])
  if drug_type
    drug_type.update(
      name: drug['name'],
      nlims_code: drug['nlims_code'],
      preferred_name: drug['preferred_name'],
      short_name: drug['short_name']
    )
  else
    Drug.create!(
      name: drug['name'],
      nlims_code: drug['nlims_code'],
      preferred_name: drug['preferred_name'],
      short_name: drug['short_name'],
      description: drug['description'],
      scientific_name: drug['scientific_name'],
      creator: User.first&.id
    )
  end
  puts "Processed Drug: #{drug['name']}"
end

# Update Organisms
organisms = test_catalog['catalog']['organisms']
organisms.each do |organism|
  puts "Organism ID: #{organism['id']}, Name: #{organism['name']}"
  organism_type = Organism.find_by(name: organism['name'])
  organism_type ||= Organism.find_by(name: organism['preferred_name'])
  organism_type ||= Organism.find_by(name: organism['iblis_mapping_name'])
  if organism_type
    organism_type.update(
      name: organism['name'],
      nlims_code: organism['nlims_code'],
      preferred_name: organism['preferred_name'],
      short_name: organism['short_name']
    )
  else
    Organism.create!(
      name: organism['name'],
      nlims_code: organism['nlims_code'],
      preferred_name: organism['preferred_name'],
      short_name: organism['short_name'],
      description: organism['description'],
      scientific_name: organism['scientific_name'],
      creator: User.first&.id
    )
  end
  puts "Processed Organism: #{organism['name']}"
end

# Update departments
departments = test_catalog['catalog']['departments']
departments.each do |department|
  puts "Department ID: #{department['id']}, Name: #{department['name']}"
  department_type = Department.find_by(name: department['name'])
  department_type ||= Department.find_by(name: department['preferred_name'])
  department_type ||= Department.find_by(name: department['iblis_mapping_name'])
  if department_type
    department_type.update(
      name: department['name'],
      nlims_code: department['nlims_code'],
      preferred_name: department['preferred_name'],
      short_name: department['short_name']
    )
  else
    Department.create!(
      name: department['name'],
      nlims_code: department['nlims_code'],
      preferred_name: department['preferred_name'],
      short_name: department['short_name'],
      description: department['description'],
      scientific_name: department['scientific_name'],
      creator: User.first&.id
    )
  end
  puts "Processed Department: #{department['name']}"

  # Delete unused departments after test types update except archives
end

# Update test_types
test_types = test_catalog['catalog']['test_types']
unwanted_tests = TestType.where(name: %w[
                                  try tr q ss cs n pll fd nn lk zz ll fd(CancerCenter) nn(CancerCenter) lk(CancerCenter) zz(CancerCenter) ll(CancerCenter)
                                ])
tis = TestIndicator.where(name: %w[ss qqq he aaa nn lk zz ll])
tests = Test.where(test_type_id: unwanted_tests.pluck(:id))
TestStatus.where(test_id: tests.pluck(:id)).delete_all
tests.delete_all
TestTypeTestIndicator.where(test_types_id: unwanted_tests.pluck(:id)).delete_all
TestTypeTestIndicator.where(test_indicators_id: tis.pluck(:id)).delete_all
SpecimenTestTypeMapping.where(test_type_id: unwanted_tests.pluck(:id)).delete_all
ExpectedTat.where(test_type_id: unwanted_tests.pluck(:id)).delete_all
unwanted_tests.delete_all
tis.delete_all

maping = JSON.parse(File.read('map.json'))
maping.each do |canonical, aliases|
  puts "Updating #{aliases.join(', ')} to #{canonical}"
  TestIndicator.where(name: aliases).update_all(name: canonical)
end

def update_test_indicators(test_catalog_test_type, test_type_record)
  return unless test_type_record.present?

  test_indicators = test_type_record.test_indicators
  test_type = test_catalog_test_type
  test_type['measures'].each do |measure|
    test_indicators.each do |indicator|
      puts "Processing Indicator: #{indicator['name']}"
      if indicator['name'].strip.downcase == measure['name'].strip.downcase || indicator['name'].strip.downcase == measure['preferred_name'].strip.downcase || indicator['name'].strip.downcase == measure['scientific_name'].strip.downcase
        puts "Updating Indicator: #{indicator['name']}"
        indicator.update(
          name: measure['name'].strip,
          nlims_code: measure['nlims_code'],
          preferred_name: measure['preferred_name'],
          short_name: measure['short_name'],
          test_indicator_type: measure['measure_type']['name'],
          unit: measure['unit']
        )
        TestTypeTestIndicator.find_or_create_by!(
          test_types_id: test_type_record.id,
          test_indicators_id: indicator['id']
        )
      elsif indicator['name'].strip.downcase == 'ca' && measure['name'].strip.downcase == 'calcium'
        puts "Updating Indicator: #{indicator['name']}"
        indicator.update(
          name: measure['name'].strip,
          nlims_code: measure['nlims_code'],
          preferred_name: measure['preferred_name'],
          short_name: measure['short_name'],
          test_indicator_type: measure['measure_type']['name'],
          unit: measure['unit']
        )
        TestTypeTestIndicator.find_or_create_by!(
          test_types_id: test_type_record.id,
          test_indicators_id: indicator['id']
        )
      else
        # Failed to match indicator, save to json file the test_type name and measures failed
        puts "Failed"
      end
    end
  end
end
# test_types.each do |test_type|
#   puts "Test Type ID: #{test_type['id']}, Name: #{test_type['name']}"
#   test_type_record = TestType.find_by(name: test_type['name'].strip)
#   test_type_record ||= TestType.find_by(name: test_type['name'])
#   test_type_record ||= TestType.find_by(name: test_type['short_name'])
#   test_type_record ||= TestType.find_by(name: test_type['preferred_name'])
#   test_type_record ||= TestType.find_by(name: test_type['iblis_mapping_name'])
#   department_id = Department.find_by(name: test_type['test_category']['name'])&.id
#   if test_type_record
#     test_type_record.update!(
#       name: test_type['name'],
#       nlims_code: test_type['nlims_code'],
#       preferred_name: test_type['preferred_name'],
#       short_name: test_type['short_name'],
#       department_id: department_id,
#       sex: test_type['can_be_done_on_sex']
#     )
#     update_test_indicators(test_type, test_type_record)
#   end
#   test_type_record2 ||= TestType.find_by(name: "#{test_type['name']} (Paeds)")
#   test_type_record2 ||= TestType.find_by(name: "#{test_type['short_name']} (Paeds)")
#   test_type_record2 ||= TestType.find_by(name: "#{test_type['preferred_name']} (Paeds)")
#   test_type_record2 ||= TestType.find_by(name: "#{test_type['iblis_mapping_name']} (Paeds)")
#   if test_type_record2
#     test_type_record2.update!(
#       nlims_code: test_type['nlims_code'],
#       short_name: test_type['short_name'],
#       department_id: department_id,
#       sex: test_type['can_be_done_on_sex']
#     )
#     update_test_indicators(test_type, test_type_record2)
#   end
#   test_type_record3 ||= TestType.find_by(name: "#{test_type['name']}(CancerCenter)")
#   test_type_record3 ||= TestType.find_by(name: "#{test_type['short_name']}(CancerCenter)")
#   test_type_record3 ||= TestType.find_by(name: "#{test_type['preferred_name']}(CancerCenter)")
#   test_type_record3 ||= TestType.find_by(name: "#{test_type['iblis_mapping_name']}(CancerCenter)")
#   if test_type_record3
#     test_type_record3.update!(
#       nlims_code: test_type['nlims_code'],
#       short_name: test_type['short_name'],
#       department_id: department_id,
#       sex: test_type['can_be_done_on_sex']
#     )
#     update_test_indicators(test_type, test_type_record3)
#   end
#   if test_type['name'].downcase == 'Hepatitis C Virus Viral load'.downcase
#     puts "Special processing for: #{test_type['name']}"
#     t = TestType.find_by(name: 'Hepatitis C')
#     t&.update!(
#       name: 'Hepatitis C Virus Viral load',
#       nlims_code: test_type['nlims_code'],
#       short_name: test_type['short_name'],
#       department_id: department_id,
#       sex: test_type['can_be_done_on_sex']
#     )
#     update_test_indicators(test_type, t)
#     tt = TestType.find_by(name: 'Hepatitis C(CancerCenter)')
#     tt&.update!(
#       nlims_code: test_type['nlims_code'],
#       short_name: test_type['short_name'],
#       department_id: department_id,
#       sex: test_type['can_be_done_on_sex']
#     )
#     update_test_indicators(test_type, tt)
#   end
#   if test_type['name'].downcase == 'Hepatitis Virus B Viral Load'.downcase
#     puts "Special processing for: #{test_type['name']}"
#     t = TestType.find_by(name: 'Hepatitis B')
#     t&.update!(
#       name: 'Hepatitis Virus B Viral Load',
#       nlims_code: test_type['nlims_code'],
#       short_name: test_type['short_name'],
#       department_id: department_id,
#       sex: test_type['can_be_done_on_sex']
#     )
#     update_test_indicators(test_type, t)
#     tt = TestType.find_by(name: 'Hepatitis B(CancerCenter)')
#     tt&.update!(
#       nlims_code: test_type['nlims_code'],
#       short_name: test_type['short_name'],
#       department_id: department_id,
#       sex: test_type['can_be_done_on_sex']
#     )
#     update_test_indicators(test_type, tt)
#   end

#   if test_type['name'].downcase == 'COVID-19 Nucleic Acid Test'.downcase
#     puts "Special processing for: #{test_type['name']}"
#     t= TestType.find_by(name: 'SARS COV 2')
#     t&.update!(
#       name: 'COVID-19 Nucleic Acid Test',
#       nlims_code: test_type['nlims_code'],
#       short_name: test_type['short_name'],
#       department_id: department_id,
#       sex: test_type['can_be_done_on_sex']
#     )
#     update_test_indicators(test_type, t)
#     tt = TestType.find_by(name: 'SARS COV 2(CancerCenter)')
#     tt&.update!(
#       nlims_code: test_type['nlims_code'],
#       short_name: test_type['short_name'],
#       department_id: department_id,
#       sex: test_type['can_be_done_on_sex']
#     )
#     update_test_indicators(test_type, tt)
#   end
#   if test_type['name'].strip.downcase == 'Erythrocyte Sedimentation Rate'.downcase
#     puts "Special processing for: #{test_type['name']}"
#     t = TestType.find_by(name: 'ESR Peads')
#     t&.update!(
#       nlims_code: test_type['nlims_code'],
#       short_name: test_type['short_name'],
#       department_id: department_id,
#       sex: test_type['can_be_done_on_sex']
#     )
#     update_test_indicators(test_type, t)
#     tt = TestType.find_by(name: 'ESR Peads(CancerCenter)')
#     tt&.update!(
#       nlims_code: test_type['nlims_code'],
#       short_name: test_type['short_name'],
#       department_id: department_id,
#       sex: test_type['can_be_done_on_sex']
#     )
#     update_test_indicators(test_type, tt)
#   end
#   next unless test_type['name'].strip.downcase == 'Prostate-Specific Antigen'.downcase

#   puts "Special processing for: #{test_type['name']}"
#   t = TestType.where(name: ['Free Prostrate Specific Antigen', 'Free Prostrate Specific Antigen(CancerCenter)'])
#   t&.update!(
#     nlims_code: test_type['nlims_code'],
#     short_name: test_type['short_name'],
#     department_id: department_id,
#     sex: test_type['can_be_done_on_sex']
#   )
#   t.each do |test_indicator|
#     update_test_indicators(test_type, test_indicator)
#   end
#   tt = TestType.where(name: ['Total Prostrate Specific Antigen', 'Total Prostrate Specific Antigen(CancerCenter)'])
#   tt&.update!(
#     nlims_code: test_type['nlims_code'],
#     short_name: test_type['short_name'],
#     department_id: department_id,
#     sex: test_type['can_be_done_on_sex']
#   )
#   tt.each do |test_indicator|
#     update_test_indicators(test_type, test_indicator)
#   end
# end

# Special mappings for test types that need custom handling
SPECIAL_MAPPINGS = {
  'hepatitis c virus viral load' => {
    targets: ['Hepatitis C', 'Hepatitis C(CancerCenter)'],
    update_name_for: 'Hepatitis C'
  },
  'hepatitis virus b viral load' => {
    targets: ['Hepatitis B', 'Hepatitis B(CancerCenter)'],
    update_name_for: 'Hepatitis B'
  },
  'covid-19 nucleic acid test' => {
    targets: ['SARS COV 2', 'SARS COV 2(CancerCenter)'],
    update_name_for: 'SARS COV 2'
  },
  'erythrocyte sedimentation rate' => {
    targets: ['ESR Peads', 'ESR Peads(CancerCenter)'],
    update_name_for: nil
  },
  'prostate-specific antigen' => {
    targets: ['Free Prostrate Specific Antigen', 'Free Prostrate Specific Antigen(CancerCenter)',
              'Total Prostrate Specific Antigen', 'Total Prostrate Specific Antigen(CancerCenter)'],
    update_name_for: nil
  },
  'tb tests' => {
    targets: ['TB Microscopic Exam', 'MTB Test', 'MTB Test(CancerCenter)'],
    update_name_for: nil
  }
}

def find_test_type_record(test_type)
  # Try to find existing record using different name fields
  TestType.find_by(name: test_type['name'].strip) ||
    TestType.find_by(name: test_type['name']) ||
    TestType.find_by(name: test_type['short_name']) ||
    TestType.find_by(name: test_type['preferred_name']) ||
    TestType.find_by(name: test_type['iblis_mapping_name'])
end

def find_variant_record(test_type, suffix)
  # Find Paeds or CancerCenter variants
  TestType.find_by(name: "#{test_type['name']}#{suffix}") ||
    TestType.find_by(name: "#{test_type['short_name']}#{suffix}") ||
    TestType.find_by(name: "#{test_type['preferred_name']}#{suffix}") ||
    TestType.find_by(name: "#{test_type['iblis_mapping_name']}#{suffix}")
end

def update_record(record, test_type, department_id, update_name = false)
  return unless record

  update_attributes = {
    nlims_code: test_type['nlims_code'],
    short_name: test_type['short_name'],
    department_id: department_id,
    sex: test_type['can_be_done_on_sex']
  }

  # Only update name if specified
  update_attributes[:name] = test_type['name'] if update_name

  record.update!(update_attributes)
  update_test_indicators(test_type, record)
end

def handle_special_mapping(test_type, department_id)
  test_name = test_type['name'].strip.downcase
  mapping = SPECIAL_MAPPINGS[test_name]
  return false unless mapping

  puts "Special processing for: #{test_type['name']}"

  mapping[:targets].each do |target_name|
    target_record = TestType.find_by(name: target_name)
    next unless target_record

    # Update name only for the specified target
    should_update_name = (target_name == mapping[:update_name_for])
    update_record(target_record, test_type, department_id, should_update_name)
  end

  true # Indicates special processing was done
end

# Main processing loop
test_types.each do |test_type|
  puts "Test Type ID: #{test_type['id']}, Name: #{test_type['name']}"

  department_id = Department.find_by(name: test_type['test_category']['name'])&.id

  # Step 1: Handle main test type record
  main_record = find_test_type_record(test_type)
  if main_record
    update_record(main_record, test_type, department_id, true)
    main_record.update!(preferred_name: test_type['preferred_name'])
  end

  # Step 2: Handle Paeds variant
  paeds_record = find_variant_record(test_type, ' (Paeds)')
  update_record(paeds_record, test_type, department_id)

  # Step 3: Handle CancerCenter variant
  cancer_center_record = find_variant_record(test_type, '(CancerCenter)')
  update_record(cancer_center_record, test_type, department_id)

  # Step 4: Handle special mappings
  handle_special_mapping(test_type, department_id)
end

TestIndicator.where('nlims_code IS NOT NULL').each do |indicator|
  TestIndicator.where(name: indicator.name)&.update!(
    nlims_code: indicator.nlims_code,
    preferred_name: indicator.preferred_name,
    short_name: indicator.short_name
  )
  TestIndicator.where(name: indicator.preferred_name)&.update!(
    nlims_code: indicator.nlims_code,
    preferred_name: indicator.preferred_name,
    short_name: indicator.short_name
  )
  TestIndicator.where(name: "#{indicator.name} (CA)")&.update!(
    nlims_code: indicator.nlims_code,
    preferred_name: indicator.preferred_name,
    short_name: indicator.short_name
  )
end
