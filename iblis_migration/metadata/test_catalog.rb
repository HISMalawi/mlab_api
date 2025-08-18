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
test_types.each do |test_type|
  puts "Test Type ID: #{test_type['id']}, Name: #{test_type['name']}"
  test_type_record = TestType.find_by(name: test_type['name'])
  test_type_record ||= TestType.find_by(name: test_type['preferred_name'])
  test_type_record ||= TestType.find_by(name: test_type['iblis_mapping_name'])
  if test_type_record
    test_type_record.update(
      name: test_type['name'],
      nlims_code: test_type['nlims_code'],
      preferred_name: test_type['preferred_name'],
      short_name: test_type['short_name']
    )
  else
    TestType.create!(
      name: test_type['name'],
      nlims_code: test_type['nlims_code'],
      preferred_name: test_type['preferred_name'],
      short_name: test_type['short_name'],
      description: test_type['description'],
      scientific_name: test_type['scientific_name'],
      creator: User.first&.id
    )
  end
  puts "Processed Test Type: #{test_type['name']}"
end
