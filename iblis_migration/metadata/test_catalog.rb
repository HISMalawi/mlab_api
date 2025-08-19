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
tests = Test.where(test_type_id: unwanted_tests.pluck(:id))
TestStatus.where(test_id: tests.pluck(:id)).destroy_all
tests.destroy_all
TestTypeTestIndicator.where(test_types_id: unwanted_tests.pluck(:id)).destroy_all
SpecimenTestTypeMapping.where(test_type_id: unwanted_tests.pluck(:id)).destroy_all
ExpectedTat.where(test_type_id: unwanted_tests.pluck(:id)).destroy_all
unwanted_tests.destroy_all

test_types.each do |test_type|
  puts "Test Type ID: #{test_type['id']}, Name: #{test_type['name']}"
  test_type_record = TestType.find_by(name: test_type['name'].strip)
  test_type_record ||= TestType.find_by(name: test_type['name'])
  test_type_record ||= TestType.find_by(name: test_type['short_name'])
  test_type_record ||= TestType.find_by(name: test_type['preferred_name'])
  test_type_record ||= TestType.find_by(name: test_type['iblis_mapping_name'])
  department_id = Department.find_by(name: test_type['test_category']['name'])&.id
  if test_type_record
    test_type_record.update!(
      name: test_type['name'],
      nlims_code: test_type['nlims_code'],
      preferred_name: test_type['preferred_name'],
      short_name: test_type['short_name'],
      department_id: department_id,
      sex: test_type['can_be_done_on_sex']
    )
    test_indicators = test_type_record.test_indicators
    test_type['measures'].each do |measure|
      test_indicators.each do |indicator|
        puts "Processing Indicator: #{indicator['name']}"
        if indicator['name'].strip.downcase == measure['name'].strip.downcase || indicator['name'].strip.downcase == measure['preferred_name'].strip.downcase
          puts "Updating Indicator: #{indicator['name']}"
          indicator.update(
            name: measure['name'].strip,
            nlims_code: measure['nlims_code'],
            preferred_name: measure['preferred_name'],
            short_name: measure['short_name'],
            test_indicator_type: measure['measure_type']['name']
          )
          TestTypeTestIndicator.find_or_create_by!(
            test_types_id: test_type_record.id,
            test_indicators_id: indicator['id']
          )
        elsif (indicator['name'].strip.downcase == 'ca' && measure['name'].strip.downcase == 'calcium')
          puts "Updating Indicator: #{indicator['name']}"
          indicator.update(
            name: measure['name'].strip,
            nlims_code: measure['nlims_code'],
            preferred_name: measure['preferred_name'],
            short_name: measure['short_name'],
            test_indicator_type: measure['measure_type']['name']
          )
          TestTypeTestIndicator.find_or_create_by!(
            test_types_id: test_type_record.id,
            test_indicators_id: indicator['id']
          )
        else
          # Failed to match indicator, save to json file the test_type name and measures failed
          File.open('failed_indicators.json', 'a') do |f|
            f.puts({ test_type: test_type['name'], measure: measure['name'] }.to_json)
          end
        end
      end
    end
  end
  test_type_record2 ||= TestType.find_by(name: "#{test_type['name']} (Paeds)")
  test_type_record2 ||= TestType.find_by(name: "#{test_type['short_name']} (Paeds)")
  test_type_record2 ||= TestType.find_by(name: "#{test_type['preferred_name']} (Paeds)")
  test_type_record2 ||= TestType.find_by(name: "#{test_type['iblis_mapping_name']} (Paeds)")
  if test_type_record2
    test_type_record2.update!(
      nlims_code: test_type['nlims_code'],
      short_name: test_type['short_name'],
      department_id: department_id,
      sex: test_type['can_be_done_on_sex']
    )
  end
  test_type_record3 ||= TestType.find_by(name: "#{test_type['name']}(CancerCenter)")
  test_type_record3 ||= TestType.find_by(name: "#{test_type['short_name']}(CancerCenter)")
  test_type_record3 ||= TestType.find_by(name: "#{test_type['preferred_name']}(CancerCenter)")
  test_type_record3 ||= TestType.find_by(name: "#{test_type['iblis_mapping_name']}(CancerCenter)")
  if test_type_record3
    test_type_record3.update!(
      nlims_code: test_type['nlims_code'],
      short_name: test_type['short_name'],
      department_id: department_id,
      sex: test_type['can_be_done_on_sex']
    )
  end
  if test_type['name'].downcase == 'Hepatitis C Virus Viral load'.downcase
    puts "Special processing for: #{test_type['name']}"
    TestType.find_by(name: 'Hepatitis C')&.update!(
      name: 'Hepatitis C Virus Viral load',
      nlims_code: test_type['nlims_code'],
      short_name: test_type['short_name'],
      department_id: department_id,
      sex: test_type['can_be_done_on_sex']
    )
    TestType.find_by(name: 'Hepatitis C(CancerCenter)')&.update!(
      nlims_code: test_type['nlims_code'],
      short_name: test_type['short_name'],
      department_id: department_id,
      sex: test_type['can_be_done_on_sex']
    )
  end
  if test_type['name'].downcase == 'Hepatitis Virus B Viral Load'.downcase
    puts "Special processing for: #{test_type['name']}"
    TestType.find_by(name: 'Hepatitis B')&.update!(
      name: 'Hepatitis Virus B Viral Load',
      nlims_code: test_type['nlims_code'],
      short_name: test_type['short_name'],
      department_id: department_id,
      sex: test_type['can_be_done_on_sex']
    )
    TestType.find_by(name: 'Hepatitis B(CancerCenter)')&.update!(
      nlims_code: test_type['nlims_code'],
      short_name: test_type['short_name'],
      department_id: department_id,
      sex: test_type['can_be_done_on_sex']
    )
  end

  if test_type['name'].downcase == 'COVID-19 Nucleic Acid Test'.downcase
    puts "Special processing for: #{test_type['name']}"
    TestType.find_by(name: 'SARS COV 2')&.update!(
      name: 'COVID-19 Nucleic Acid Test',
      nlims_code: test_type['nlims_code'],
      short_name: test_type['short_name'],
      department_id: department_id,
      sex: test_type['can_be_done_on_sex']
    )
    TestType.find_by(name: 'SARS COV 2(CancerCenter)')&.update!(
      nlims_code: test_type['nlims_code'],
      short_name: test_type['short_name'],
      department_id: department_id,
      sex: test_type['can_be_done_on_sex']
    )
  end
  if test_type['name'].strip.downcase == 'Erythrocyte Sedimentation Rate'.downcase
    puts "Special processing for: #{test_type['name']}"
    TestType.find_by(name: 'ESR Peads')&.update!(
      nlims_code: test_type['nlims_code'],
      short_name: test_type['short_name'],
      department_id: department_id,
      sex: test_type['can_be_done_on_sex']
    )
    TestType.find_by(name: 'ESR Peads(CancerCenter)')&.update!(
      nlims_code: test_type['nlims_code'],
      short_name: test_type['short_name'],
      department_id: department_id,
      sex: test_type['can_be_done_on_sex']
    )
  end
  next unless test_type['name'].strip.downcase == 'Prostate-Specific Antigen'.downcase

  puts "Special processing for: #{test_type['name']}"
  TestType.where(name: ['Free Prostrate Specific Antigen', 'Free Prostrate Specific Antigen(CancerCenter)'])&.update!(
    nlims_code: test_type['nlims_code'],
    short_name: test_type['short_name'],
    department_id: department_id,
    sex: test_type['can_be_done_on_sex']
  )
  TestType.where(name: ['Total Prostrate Specific Antigen', 'Total Prostrate Specific Antigen(CancerCenter)'])&.update!(
    nlims_code: test_type['nlims_code'],
    short_name: test_type['short_name'],
    department_id: department_id,
    sex: test_type['can_be_done_on_sex']
  )
end

TestIndicator.where("nlims_code IS NOT NULL").each do |indicator|
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
