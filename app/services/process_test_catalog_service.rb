# frozen_string_literal: true

# module ProcessTestCatalog
class ProcessTestCatalogService
  attr_reader :version

  def initialize(version)
    @version = version
    @version ||= TestCatalogVersion.last&.version
    @version ||= '0'
  end

  def check_new_version
    Nlims::Sync.check_new_test_catalog_version(@version)
  end

  def test_catalog
    Nlims::Sync.get_test_catalog(@version)
  end

  def test_catalog_versions
    TestCatalogVersion.all
  end

  def process_test_catalog(test_catalog, sections = nil)
    return false if test_catalog.nil?

    ActiveRecord::Base.transaction do
      create_or_update_specimens(test_catalog[:specimen_types] || [])
      create_or_update_drugs(test_catalog[:drugs] || [])
      create_or_update_organisms(test_catalog[:organisms] || [])
      departments = test_catalog[:departments] || []
      departments.each do |item|
        create_or_update_department(item)
      end
      if sections.present?
        test_types = test_catalog[:test_types] || []
        test_types.each do |item|
          record = find_or_initialize_test_type(item)
          test_type = create_or_update_record(record, item)
          if sections.include?('test_types')
            create_or_update_test_indicators(test_type, item[:measures])
            create_or_update_tat(test_type.id, item[:targetTAT])
          end
          test_type.specimens = create_or_update_specimens(item[:specimen_types]) if sections.include?('specimens')
          test_type.organisms = create_or_update_organisms(item[:organisms]) if sections.include?('organisms')
          if sections.include?('lab_test_sites')
            test_type.lab_test_sites = create_or_update_lab_test_sites(item[:lab_test_sites])
          end
        end
      else
        create_or_update_test_types(test_catalog[:test_types] || [])
      end
      create_or_update_test_panels(test_catalog[:test_panels] || [])
    end
    TestCatalogSyncTrail.find_or_create_by!(version: @version).update(section: 'test_types', synced: true)
    true
  end

  def create_or_update_record(record, data)
    if record.new_record?
      record.name = data[:name]&.strip
      record.nlims_code = data[:nlims_code]
      record.preferred_name = unique_preferred_name(data[:preferred_name], record)
      record.moh_code = data[:moh_code]
      record.loinc_code = data[:loinc_code]
      record.short_name = data[:short_name]
      record.description = data[:description]
      record.save!
    else
      attrs = {
        name: data[:name]&.strip,
        nlims_code: data[:nlims_code],
        moh_code: data[:moh_code],
        loinc_code: data[:loinc_code],
        short_name: data[:short_name],
        # Never overwrite description if the user has already customised it
        description: record.description.present? ? record.description : data[:description],
        updated_date: Time.current
      }
      # If preferred_name is blank, assign only if the desired value is available.
      unless record.preferred_name.present?
        attrs[:preferred_name] = unique_preferred_name(data[:preferred_name], record)
      end
      # Use update_columns to bypass model validations (sync is a trusted source).
      # This prevents the preferred_name uniqueness validator from firing on the
      # existing in-memory value even when preferred_name is not being changed.
      record.update_columns(attrs)
    end
    record
  end

  # Returns name only when it is not already taken by another non-retired record of the same type.
  # Returns nil otherwise so the field is simply left blank.
  def unique_preferred_name(name, record)
    return nil if name.blank?

    taken = record.class
                  .where(preferred_name: name)
                  .where.not(id: record.id || 0)
                  .exists?
    taken ? nil : name
  end

  def create_or_update_drugs(drugs)
    drugs.map do |item|
      record = Drug.find_by(nlims_code: item[:nlims_code]) if item[:nlims_code].present?
      record ||= Drug.find_by(scientific_name: item[:scientific_name]) if item[:scientific_name].present?
      record ||= Drug.find_by(name: item[:name])
      record ||= Drug.find_by(name: item[:iblis_mapping_name]) if item[:iblis_mapping_name].present?
      record ||= Drug.new
      create_or_update_record(record, item)
    end
  end

  def create_or_update_organisms(organisms)
    organisms = organisms.map do |item|
      record = Organism.find_by(nlims_code: item[:nlims_code]) if item[:nlims_code].present?
      record ||= Organism.find_by(scientific_name: item[:scientific_name]) if item[:scientific_name].present?
      record ||= Organism.find_by(name: item[:name])
      record ||= Organism.find_by(name: item[:iblis_mapping_name]) if item[:iblis_mapping_name].present?
      record ||= Organism.new
      record = create_or_update_record(record, item)
      record.drugs = create_or_update_drugs(item[:drugs])
      record
    end
    TestCatalogSyncTrail.find_or_create_by!(version: @version).update(section: 'organisms', synced: true)
    organisms
  end

  def create_or_update_specimens(specimens)
    specimen = specimens.map do |item|
      record = Specimen.find_by(nlims_code: item[:nlims_code]) if item[:nlims_code].present?
      record ||= Specimen.find_by(scientific_name: item[:scientific_name]) if item[:scientific_name].present?
      record ||= Specimen.find_by(name: item[:name])
      record ||= Specimen.find_by(name: item[:iblis_mapping_name]) if item[:iblis_mapping_name].present?
      record ||= Specimen.new
      create_or_update_record(record, item)
    end
    TestCatalogSyncTrail.find_or_create_by!(version: @version).update(section: 'specimens', synced: true)
    specimen
  end

  def create_or_update_department(item)
    record = Department.find_by(nlims_code: item[:nlims_code]) if item[:nlims_code].present?
    record ||= Department.find_by(scientific_name: item[:scientific_name]) if item[:scientific_name].present?
    record ||= Department.find_by(name: item[:name])
    record ||= Department.find_by(name: item[:iblis_mapping_name]) if item[:iblis_mapping_name].present?
    record ||= Department.new
    department = create_or_update_record(record, item)
    TestCatalogSyncTrail.find_or_create_by!(version: @version).update(section: 'departments', synced: true)
    department
  end

  def create_or_update_test_indicator_ranges(test_indicator_ranges, test_indicator_id, test_type)
    # If the test type already has ranges for this indicator, the user may have
    # customised them via the UI — skip the sync to avoid overwriting their work.
    existing_ranges = TestIndicatorRange.where(test_indicator_id:, test_type_id: test_type.id)
    return existing_ranges if existing_ranges.exists?

    unless test_indicator_ranges.empty?
      existing_ranges.each do |test_indicator_range|
        test_indicator_range.void('Removed from test indicator')
      end
    end
    test_indicator_ranges.map do |test_indicator_range|
      TestIndicatorRange.find_or_create_by!(
        test_indicator_id:,
        test_type_id: test_type.id,
        sex: test_indicator_range[:sex] || 'Both',
        min_age: test_indicator_range[:age_min],
        max_age: test_indicator_range[:age_max],
        lower_range: test_indicator_range[:range_lower],
        upper_range: test_indicator_range[:range_upper],
        value: test_indicator_range[:value],
        interpretation: test_indicator_range[:interpretation]
      )
    end
  end

  def create_or_update_test_indicators(test_type, test_indicators)
    test_indicators.map do |item|
      record = TestIndicator.find_by(nlims_code: item[:nlims_code]) if item[:nlims_code].present?
      record ||= TestIndicator.find_by(scientific_name: item[:scientific_name]) if item[:scientific_name].present?
      record ||= TestIndicator.find_by(name: item[:name]&.strip)
      record ||= TestIndicator.find_by(name: item[:iblis_mapping_name]) if item[:iblis_mapping_name].present?
      record ||= TestIndicator.new
      if record.new_record?
        record.name = item[:name]&.strip
        # record.test_indicator_type = item[:measure_type][:name]
        # record.unit = item[:unit] if item[:unit].present?
        record.save!
      end
      indicator = create_or_update_record(record, item)
      duplicates = test_type.test_type_test_indicators.where(test_indicators_id: indicator.id)
      duplicates.offset(1).destroy_all if duplicates.count > 1
      join_record = test_type.test_type_test_indicators.find_or_create_by!(test_indicators_id: indicator.id)
      # Only set unit and test_indicator_type if the join record was just created;
      # do not overwrite values the user has already configured via the UI.
      join_record.unit = item[:unit] unless join_record.unit.present?
      join_record.test_indicator_type = item.dig(:measure_type, :name) unless join_record.test_indicator_type.present?
      join_record.save! if join_record.changed?
      create_or_update_test_indicator_ranges(item[:measure_ranges_attributes], indicator.id, test_type)
      indicator
    end
    # voids removed indicators
    existing_indicator_ids = test_indicators.map do |ti|
      record = TestIndicator.find_by(nlims_code: ti[:nlims_code]) if ti[:nlims_code].present?
      record ||= TestIndicator.find_by(scientific_name: ti[:scientific_name]) if ti[:scientific_name].present?
      record ||= TestIndicator.find_by(name: ti[:name]&.strip)
      record ||= TestIndicator.find_by(name: ti[:iblis_mapping_name]) if ti[:iblis_mapping_name].present?
      record&.id
    end.compact
    test_type.test_type_test_indicators.each do |ttti|
      next if existing_indicator_ids.include?(ttti.test_indicators_id)

      ttti.void('Removed from test type')
    end
  end

  def create_or_update_test_types(test_types)
    test_types.each do |item|
      record = find_or_initialize_test_type(item)
      test_type = create_or_update_record(record, item)
      create_or_update_test_indicators(test_type, item[:measures])
      test_type.specimens = create_or_update_specimens(item[:specimen_types])
      test_type.organisms = create_or_update_organisms(item[:organisms])
      create_or_update_tat(test_type.id, item[:targetTAT])
      test_type.lab_test_sites = create_or_update_lab_test_sites(item[:lab_test_sites])
    end
  end

  def create_or_update_tat(test_type_id, tat)
    tat = '24 Hours' if tat.nil?

    tat_value = tat.split(' ').first
    tat_unit = tat.split(' ').last

    tat_unit = case tat_unit.downcase
               when /h/
                 'Hours'
               when /d/
                 'Days'
               when /m/
                 'Minutes'
               else
                 'Hours'
               end
    tat_record = ExpectedTat.find_by(test_type_id:)
    tat_record ||= ExpectedTat.new
    return unless tat_record.new_record?

    tat_record.value = tat_value || 24
    tat_record.unit = tat_unit || 'Hours'
    tat_record.test_type_id = test_type_id
    tat_record.save!
    # If a user has already customised the TAT, do not overwrite it on sync
  end

  def create_or_update_lab_test_sites(lab_test_sites)
    lab_test_sites = lab_test_sites.map do |item|
      record = LabTestSite.find_by(name: item[:name])
      record ||= LabTestSite.new
      if record.new_record?
        record.name = item[:name]
        record.description = item[:description]
        record.save!
      else
        record.update!(name: item[:name], description: item[:description])
      end
      record
    end
    TestCatalogSyncTrail.find_or_create_by!(version: @version).update(section: 'lab_test_sites', synced: true)
    lab_test_sites
  end

  def create_or_update_test_panels(test_panels)
    test_panels = test_panels.map do |item|
      record = TestPanel.find_by(nlims_code: item[:nlims_code]) if item[:nlims_code].present?
      record ||= TestPanel.find_by(scientific_name: item[:scientific_name]) if item[:scientific_name].present?
      record ||= TestPanel.find_by(name: item[:name])
      record ||= TestPanel.new
      if record.new_record?
        record.name = item[:name]
        record.description = item[:description]
        record.save!
      else
        record = create_or_update_record(record, item)
      end
      record.test_types = TestType.where(name: item[:test_types].map { |tt| tt[:name] })
    end
    TestCatalogSyncTrail.find_or_create_by!(version: @version).update(section: 'test_panels', synced: true)
    test_panels
  end

  def find_or_initialize_test_type(item)
    puts "Processing test type: #{item[:name]}"
    record = TestType.find_by(nlims_code: item[:nlims_code], disabled: false) if item[:nlims_code].present?
    # record ||= TestType.find_by(scientific_name: item[:scientific_name]) if item[:scientific_name].present?
    record ||= TestType.find_by(name: item[:name]&.strip, disabled: false)
    # record ||= TestType.find_by(name: item[:iblis_mapping_name]) if item[:iblis_mapping_name].present?
    record ||= TestType.new
    if record.new_record?
      record.name = item[:name]&.strip
      record.preferred_name = unique_preferred_name(item[:preferred_name], record)
      record.department = create_or_update_department(item[:test_category])
      record.sex = item[:can_be_done_on_sex] if item[:can_be_done_on_sex].present?
      record.can_be_ordered = true
      record.disabled = false
      # New records use save! (validations are safe here since preferred_name was pre-checked)
      record.save!
    elsif record.changed?
      # For existing records: department, sex, can_be_ordered, and disabled are
      # user-editable via the UI and must not be overwritten on sync.
      # Use update_columns to bypass model validations (preferred_name uniqueness)
      # which would fire on the existing in-memory value even when not being changed.
      record.update_columns(
        name: record.name,
        nlims_code: record.nlims_code,
        updated_date: Time.current
      )
    end
    record
  end
end
