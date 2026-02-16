# frozen_string_literal: true

# Read a json file
test_catalog = JSON.parse(File.read('test_catalog_version.json'))

puts 'Initializing processing of test types'
# Uncomment validation for department and name for test type before running this block
[TestIndicator, TestType, Drug, Organism].each do |model|
  model.find_each do |record|
    cleaned_name = record.name.strip
    record.update_columns(name: cleaned_name) if record.name != cleaned_name
  end
end

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
unwanted_tests = TestType.where(name: %w[
                                  try tr q ss cs n pll fd nn lk zz ll fd(CancerCenter) nn(CancerCenter) lk(CancerCenter) zz(CancerCenter) ll(CancerCenter)
                                ])
tis = TestIndicator.unscoped.where(name: %w[ss qqq he aaa nn lk zz ll])
ActiveRecord::Base.transaction do
  unwanted_test_type_ids = unwanted_tests.pluck(:id)
  unwanted_indicator_ids = tis.pluck(:id)

  # 1️⃣ Test statuses
  TestStatus.unscoped
            .where(test_id: Test.unscoped.where(test_type_id: unwanted_test_type_ids).pluck(:id))
            .delete_all

  # 2️⃣ Tests (CRITICAL: unscoped)
  Test.unscoped
      .where(test_type_id: unwanted_test_type_ids)
      .delete_all

  # 3️⃣ Test ↔ Indicator mappings
  TestTypeTestIndicator.unscoped
                       .where(test_types_id: unwanted_test_type_ids)
                       .or(
                         TestTypeTestIndicator.unscoped.where(test_indicators_id: unwanted_indicator_ids)
                       )
                       .delete_all

  # 4️⃣ Indicator ranges
  TestIndicatorRange.unscoped
                    .where(test_indicator_id: unwanted_indicator_ids)
                    .delete_all

  # 5️⃣ Specimen mappings
  SpecimenTestTypeMapping.unscoped
                         .where(test_type_id: unwanted_test_type_ids)
                         .delete_all

  # 6️⃣ Expected TATs
  ExpectedTat.unscoped
             .where(test_type_id: unwanted_test_type_ids)
             .delete_all

  # 7️⃣ Test indicators
  TestIndicator.unscoped
               .where(id: unwanted_indicator_ids)
               .delete_all

  # 8️⃣ Test types (LAST)
  TestType.unscoped
          .where(id: unwanted_test_type_ids)
          .delete_all
end

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
      if indicator['name']&.strip&.downcase == measure['name']&.strip&.downcase || indicator['name']&.strip&.downcase == measure['preferred_name']&.strip&.downcase || indicator['name']&.strip&.downcase == measure['scientific_name']&.strip&.downcase
        puts "Updating Indicator: #{indicator['name']}"
        indicator.update(
          name: measure['name']&.strip,
          nlims_code: measure['nlims_code'],
          preferred_name: measure['preferred_name'],
          short_name: measure['short_name']
        )
        tt = TestTypeTestIndicator.find_or_create_by!(
          test_types_id: test_type_record.id,
          test_indicators_id: indicator['id']
        )
        tt.update(
          test_indicator_type: measure['measure_type']['name'],
          unit: measure['unit']
        )
      elsif indicator['name']&.strip&.downcase == 'ca' && measure['name']&.strip&.downcase == 'calcium'
        puts "Updating Indicator: #{indicator['name']}"
        indicator.update(
          name: measure['name']&.strip,
          nlims_code: measure['nlims_code'],
          preferred_name: measure['preferred_name'],
          short_name: measure['short_name']
        )
        tt = TestTypeTestIndicator.find_or_create_by!(
          test_types_id: test_type_record.id,
          test_indicators_id: indicator['id']
        )
        tt.update(
          test_indicator_type: measure['measure_type']['name'],
          unit: measure['unit']
        )
      else
        puts 'go to next'
        next
      end
    end
  end
end

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
  'hepatitis b test' => {
    targets: ['Hepatitis B Antigen Test'],
    update_name_for: 'Hepatitis B Antigen Test'
  },
  'covid-19 nucleic acid test' => {
    targets: ['SARS COV 2', 'SARS COV 2(CancerCenter)'],
    update_name_for: 'SARS COV 2'
  },
  'erythrocyte sedimentation rate' => {
    targets: ['ESR Peads', 'ESR Peads(CancerCenter)'],
    update_name_for: nil
  },
  'rapid hiv test' => {
    targets: ['HIV', 'HIV(CancerCenter)'],
    update_name_for: nil
  },
  'prostate-specific antigen' => {
    targets: ['Free Prostrate Specific Antigen', 'Free Prostrate Specific Antigen(CancerCenter)',
              'Total Prostrate Specific Antigen', 'Total Prostrate Specific Antigen(CancerCenter)'],
    update_name_for: nil
  },
  'tb tests' => {
    targets: ['TB Microscopic Exam', 'MTB Test', 'MTB Test(CancerCenter)', 'GeneXpert',
              'Mycobacteria Tuberculosis test'],
    update_name_for: nil
  },
  # 'hiv viral load quantitative hiv nucleic acid test' => {
  #   targets: ['HIV Viral Load', 'HIV Viral Load(CancerCenter)', 'Viral Load'],
  #   update_name_for: nil
  # },
  'cryptococcus antigen' => {
    targets: ['CSF CrAg LFA'],
    update_name_for: nil
  },
  'syphilis test' => {
    targets: ['Syphilis (Paeds)']
  },
  'amylase' => {
    targets: ['SERUM AMYLASE'],
    update_name_for: nil
  },
  'haemoglobin' => {
    targets: ['haemoglobine Test'],
    update_name_for: nil
  },
  'ziehl-neelsen (zn) stain' => {
    targets: ['ZN Stain'],
    update_name_for: nil
  },
  'antibodies to hepatitis c virus' => {
    targets: ['Hepatitis C antibody test'],
    update_name_for: 'Hepatitis C antibody test'
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

  # Skip validation for disabled records to avoid uniqueness conflicts
  if record.disabled?
    record.update_columns(update_attributes)
  else
    record.update!(update_attributes)
  end

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
    target_record.update_column(:disabled, true) unless should_update_name
    update_record(target_record, test_type, department_id, should_update_name)
  end

  true # Indicates special processing was done
end

puts 'Fixing Paeds and CancerCenter tests...'
paeds_tests = TestType.where("name LIKE '%(Paeds)'")
cancer_tests = TestType.where("name LIKE '%(Cancer)'")
paeds_tests.update_all(disabled: true)
cancer_tests.update_all(disabled: true)
dp = Department.unscoped.where(retired: 1).pluck(:id)
TestType.where(department_id: dp).update_all(department_id: Department.first.id)
TestType.all.each do |test_type|
  # Use update_columns to bypass validation and avoid conflicts
  test_type.update_columns(preferred_name: test_type.name)
end
puts 'Fixed Paeds and CancerCenter tests.'

# Main processing loop
def main_processing(test_types)
  test_types.each do |test_type|
    puts "Test Type ID: #{test_type['id']}, Name: #{test_type['name']}"

    department_id = Department.find_by(name: test_type['test_category']['name'])&.id

    # Step 1: Handle main test type record FIRST to avoid validation conflicts
    main_record = find_test_type_record(test_type)
    if main_record
      update_record(main_record, test_type, department_id, true)
      # main_record.update!(preferred_name: test_type['preferred_name'])
      main_record.update!(can_be_ordered: true, disabled: false)
    end

    # Step 2: Handle Paeds variant - use update_columns to bypass validation
    paeds_record = find_variant_record(test_type, ' (Paeds)')
    if paeds_record
      paeds_record.update_columns(disabled: true, preferred_name: paeds_record.name, can_be_ordered: false)
      update_record(paeds_record, test_type, department_id)
    end

    # Step 3: Handle CancerCenter variant - use update_columns to bypass validation
    cancer_center_record = find_variant_record(test_type, '(CancerCenter)')
    if cancer_center_record
      cancer_center_record.update_columns(disabled: true, preferred_name: cancer_center_record.name,
                                          can_be_ordered: false)
      update_record(cancer_center_record, test_type, department_id)
    end

    # Step 4: Handle special mappings
    handle_special_mapping(test_type, department_id)
  end
end

main_processing(test_catalog['catalog']['test_types'])
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

# Have a file of its own from here
TestIndicator.find_by_sql("
  UPDATE test_indicators ti
  JOIN (
      SELECT id
      FROM (
          SELECT id,
                ROW_NUMBER() OVER (PARTITION BY name ORDER BY id) AS row_num
          FROM test_indicators
      ) ranked
      WHERE row_num > 1
  ) dupes ON ti.id = dupes.id
  SET ti.retired = #{User.first&.id || 1}, ti.retired_by = 1, ti.retired_reason = 'Duplicate retired'
")

retired_test_indicators = TestIndicator.unscoped.where(retired: 1)
retired_test_indicators.each do |indicator|
  active_indicator_id = TestIndicator.find_by(name: indicator.name)&.id
  next unless active_indicator_id

  puts "Updating references from retired indicator #{indicator.id} to active indicator #{active_indicator_id} for test type test indicators"
  TestTypeTestIndicator.where(test_indicators_id: indicator.id).update_all(test_indicators_id: active_indicator_id)
end

# Helper method to format time duration
def format_time(seconds)
  return '0s' if seconds <= 0

  hours = seconds / 3600
  minutes = (seconds % 3600) / 60
  secs = seconds % 60

  parts = []
  parts << "#{hours}h" if hours > 0
  parts << "#{minutes}m" if minutes > 0 || hours > 0
  parts << "#{secs}s"
  parts.join(' ')
end

def update_test_results_with_active_indicators
  retired_indicators = TestIndicator.unscoped.where(retired: 1).pluck(:id, :name)

  # Calculate total rows to update
  total_to_update = 0
  indicator_counts = {}
  retired_indicators.each do |retired_id, name|
    active_indicator = TestIndicator.find_by(name: name, retired: 0)
    next unless active_indicator

    count = TestResult.where(test_indicator_id: retired_id).count
    indicator_counts[retired_id] = { name: name, active_id: active_indicator.id, count: count }
    total_to_update += count
  end

  puts '=' * 80
  puts "Total test results to migrate: #{total_to_update.to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1,').reverse}"
  puts "Number of retired indicators: #{indicator_counts.size}"
  puts '=' * 80

  start_time = Time.now
  total_processed = 0

  indicator_counts.each_with_index do |(retired_id, info), index|
    current_index = index + 1
    puts "\n[#{current_index}/#{indicator_counts.size}] Migrating indicator: #{info[:name]}"
    puts "  From ID: #{retired_id} -> To ID: #{info[:active_id]}"
    puts "  Rows to update: #{info[:count].to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1,').reverse}"

    indicator_processed = 0

    # Process in batches of 10,000
    loop do
      ActiveRecord::Base.connection.execute(<<-SQL.squish)
      UPDATE test_results
      SET test_indicator_id = #{info[:active_id]}
      WHERE test_indicator_id = #{retired_id}
      LIMIT 10000
      SQL

      affected_rows = ActiveRecord::Base.connection.raw_connection.affected_rows
      break if affected_rows == 0

      indicator_processed += affected_rows
      total_processed += affected_rows

      percentage = (total_processed.to_f / total_to_update * 100).round(2)
      remaining = total_to_update - total_processed

      # Calculate elapsed and estimated time
      elapsed_seconds = (Time.now - start_time).to_i
      elapsed_time = format_time(elapsed_seconds)

      # Estimate time remaining based on processing rate
      rate = total_processed.to_f / elapsed_seconds if elapsed_seconds > 0
      est_remaining_seconds = rate && rate > 0 ? (remaining / rate).to_i : 0
      est_remaining_time = format_time(est_remaining_seconds)

      puts "\n[#{current_index}/#{indicator_counts.size}] Migrating indicator: #{info[:name]}"
      puts "    Batch: #{affected_rows.to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1,').reverse} rows | " \
           "Indicator total: #{indicator_processed.to_s.reverse.gsub(/(\d{3})(?=\d)/,
                                                                     '\\1,').reverse}/#{info[:count].to_s.reverse.gsub(
                                                                       /(\d{3})(?=\d)/, '\\1,'
                                                                     ).reverse} | " \
           "Overall: #{percentage}% | Remaining: #{remaining.to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1,').reverse}"
      puts "    Elapsed: #{elapsed_time} | Est. remaining: #{est_remaining_time}"

      sleep 0.1 # Give DB a breather
    end

    puts "  ✓ Completed indicator: #{info[:name]} (#{indicator_processed} rows migrated)"
  end

  total_elapsed = (Time.now - start_time).to_i
  puts "\n" + '=' * 80
  puts "Migration complete! Total rows updated: #{total_processed.to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1,').reverse}"
  puts "Total time elapsed: #{format_time(total_elapsed)}"
  puts '=' * 80
end

update_test_results_with_active_indicators

TestPanel.find_each do |panel|
  puts "Fixing Panel: #{panel.name}"

  # Skip panels that still have test types (Rails-level)
  next if panel.test_types.exists?

  # 🔥 Remove join-table references FIRST
  TestTypePanelMapping.unscoped
                      .where(test_panel_id: panel.id)
                      .delete_all

  # Nullify tests just in case
  Test.unscoped
      .where(test_panel_id: panel.id)
      .update_all(test_panel_id: nil)

  # Now safe to delete
  panel.delete

  puts "Fixed Panel: #{panel.name}"
end

p = ProcessTestCatalogService.new(nil)
p.process_test_catalog(test_catalog['catalog'].deep_symbolize_keys)

TestType.unscoped.where(can_be_ordered: false).each do |test_type|
  preferred_name = test_type.preferred_name || test_type.name
  # Use update_columns to bypass validation when disabling
  test_type.update_columns(preferred_name: preferred_name, disabled: true)
end
main_processing(test_catalog['catalog']['test_types'])
update_test_results_with_active_indicators

p = ProcessTestCatalogService.new(nil)
puts 'Final processing of test catalog...'
p.process_test_catalog(test_catalog['catalog'].deep_symbolize_keys)

TestType.unscoped.where(can_be_ordered: false).each do |test_type|
  preferred_name = test_type.preferred_name || test_type.name
  # Use update_columns to bypass validation when disabling
  test_type.update_columns(preferred_name: preferred_name, disabled: true)
end
puts 'Finished processing test catalog.'
