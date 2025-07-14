# frozen_string_literal: true

# module ProcessTestCatalog
module ProcessTestCatalogService
  class << self
    def check_new_version(current_version)
      Nlims::Sync.check_new_test_catalog_version(current_version || '0')
    end

    def get_test_catalog(version)
      Nlims::Sync.get_test_catalog(version)
    end

    def get_test_catalog_versions()
      Nlims::Sync.get_test_catalog_versions
    end

    def process_test_catalog(test_catalog, sections = nil)
      return false if test_catalog.nil?

      ActiveRecord::Base.transaction do
        if sections.nil?
          # If no sections specified, sync everything
          create_or_update_test_types(test_catalog[:test_types])
        else
          # Process only requested sections
          test_types = test_catalog[:test_types] || []
          test_types.each do |item|
            record = find_or_initialize_test_type(item)

            # Base test type always gets processed
            if record.new_record?
              record.name = item[:name]
              record.department = create_or_update_department(item[:test_category])
              record.sex = item[:can_be_done_on_sex] if item[:can_be_done_on_sex].present?
              record.save!
            end
            test_type = create_or_update_record(record, item)

            # Process only selected sections
            if sections.include?('test_types')
              # The test_types section includes indicators and tat
              test_type.test_indicators = create_or_update_test_indicators(item[:measures])
              create_or_update_tat(test_type.id, item[:targetTAT])
            end
            test_type.specimens = create_or_update_specimens(item[:specimen_types]) if sections.include?('specimens')
            test_type.organisms = create_or_update_organisms(item[:organisms]) if sections.include?('organisms')
            test_type.lab_test_sites = create_or_update_lab_test_sites(item[:lab_test_sites]) if sections.include?('lab_test_sites')
          end
        end
      end
      true
    end

    def create_or_update_record(record, data)
      if record.new_record?
        record.name = data[:name]
        record.nlims_code = data[:nlims_code]
        record.preferred_name = data[:preferred_name]
        record.moh_code = data[:moh_code]
        record.loinc_code = data[:loinc_code]
        record.short_name = data[:short_name]
        record.description = data[:description]
        record.save!
      else
        record.update!(
          name: data[:name],
          nlims_code: data[:nlims_code],
          preferred_name: data[:preferred_name],
          moh_code: data[:moh_code],
          loinc_code: data[:loinc_code],
          short_name: data[:short_name],
          description: data[:description]
        )
      end
      record
    end

    def create_or_update_drugs(drugs)
      drugs.map do |item|
        begin
          # First, try to find the drug by various identifiers
          record = Drug.find_by(nlims_code: item[:nlims_code]) if item[:nlims_code].present?
          record ||= Drug.find_by(scientific_name: item[:scientific_name]) if item[:scientific_name].present?
          record ||= Drug.find_by(name: item[:name])
          record ||= Drug.find_by(name: item[:iblis_mapping_name]) if item[:iblis_mapping_name].present?

          # If we found an existing record, update it
          if record.present?
            create_or_update_record(record, item)
          else
            # Check if there's any drug with the same name to avoid "name has already been taken" error
            if Drug.exists?(name: item[:name])
              # Log that we're skipping this record due to duplicate name
              Rails.logger.info("Skipping drug creation - name '#{item[:name]}' already exists")
              # Return the existing record instead of creating a new one
              Drug.find_by(name: item[:name])
            else
              # Create a new record if no duplicate exists
              create_or_update_record(Drug.new, item)
            end
          end
        rescue ActiveRecord::RecordInvalid => e
          # Log the validation error but don't halt the process
          Rails.logger.error("Failed to create/update drug '#{item[:name]}': #{e.message}")
          # Return the existing record if possible
          Drug.find_by(name: item[:name]) || nil
        end
      end
    end

    def create_or_update_organisms(organisms)
      organisms.map do |item|
        begin
          # First, try to find the organism by various identifiers
          record = Organism.find_by(nlims_code: item[:nlims_code]) if item[:nlims_code].present?
          record ||= Organism.find_by(scientific_name: item[:scientific_name]) if item[:scientific_name].present?
          record ||= Organism.find_by(name: item[:name])
          record ||= Organism.find_by(name: item[:iblis_mapping_name]) if item[:iblis_mapping_name].present?

          # If we found an existing record, update it
          if record.present?
            record = create_or_update_record(record, item)
          else
            # Check if there's any organism with the same name to avoid "name has already been taken" error
            if Organism.exists?(name: item[:name])
              # Log that we're skipping this record due to duplicate name
              Rails.logger.info("Skipping organism creation - name '#{item[:name]}' already exists")
              # Return the existing record instead of creating a new one
              record = Organism.find_by(name: item[:name])
            else
              # Create a new record if no duplicate exists
              record = create_or_update_record(Organism.new, item)
            end
          end

          # Add drugs to the organism if they exist
          record.drugs = create_or_update_drugs(item[:drugs]) if record.present? && item[:drugs].present?
          record
        rescue ActiveRecord::RecordInvalid => e
          # Log the validation error but don't halt the process
          Rails.logger.error("Failed to create/update organism '#{item[:name]}': #{e.message}")
          # Return the existing record if possible
          Organism.find_by(name: item[:name]) || nil
        end
      end
    end

    def create_or_update_specimens(specimens)
      specimens.map do |item|
        begin
          # First, try to find the specimen by various identifiers
          record = Specimen.find_by(nlims_code: item[:nlims_code]) if item[:nlims_code].present?
          record ||= Specimen.find_by(scientific_name: item[:scientific_name]) if item[:scientific_name].present?
          record ||= Specimen.find_by(name: item[:name])
          record ||= Specimen.find_by(name: item[:iblis_mapping_name]) if item[:iblis_mapping_name].present?

          # If we found an existing record, update it
          if record.present?
            create_or_update_record(record, item)
          else
            # Check if there's any specimen with the same name to avoid "name has already been taken" error
            if Specimen.exists?(name: item[:name])
              # Log that we're skipping this record due to duplicate name
              Rails.logger.info("Skipping specimen creation - name '#{item[:name]}' already exists")
              # Return the existing record instead of creating a new one
              Specimen.find_by(name: item[:name])
            else
              # Create a new record if no duplicate exists
              create_or_update_record(Specimen.new, item)
            end
          end
        rescue ActiveRecord::RecordInvalid => e
          # Log the validation error but don't halt the process
          Rails.logger.error("Failed to create/update specimen '#{item[:name]}': #{e.message}")
          # Return the existing record if possible
          Specimen.find_by(name: item[:name]) || nil
        end
      end
    end

    def create_or_update_department(item)
      begin
        # First, try to find the department by various identifiers
        record = Department.find_by(nlims_code: item[:nlims_code]) if item[:nlims_code].present?
        record ||= Department.find_by(scientific_name: item[:scientific_name]) if item[:scientific_name].present?
        record ||= Department.find_by(name: item[:name])
        record ||= Department.find_by(name: item[:iblis_mapping_name]) if item[:iblis_mapping_name].present?

        # If we found an existing record, update it
        if record.present?
          create_or_update_record(record, item)
        else
          # Check if there's any department with the same name to avoid "name has already been taken" error
          if Department.exists?(name: item[:name])
            # Log that we're skipping this record due to duplicate name
            Rails.logger.info("Skipping department creation - name '#{item[:name]}' already exists")
            # Return the existing record instead of creating a new one
            Department.find_by(name: item[:name])
          else
            # Create a new record if no duplicate exists
            create_or_update_record(Department.new, item)
          end
        end
      rescue ActiveRecord::RecordInvalid => e
        # Log the validation error but don't halt the process
        Rails.logger.error("Failed to create/update department '#{item[:name]}': #{e.message}")
        # Return the existing record if possible
        Department.find_by(name: item[:name]) || nil
      end
    end

    def create_or_update_test_indicator_ranges(test_indicator_ranges, test_indicator_id)
      unless test_indicator_ranges.empty?
        TestIndicatorRange.where(test_indicator_id:).each do |test_indicator_range|
          test_indicator_range.void('Removed from test indicator')
        end
      end
      test_indicator_ranges.map do |test_indicator_range|
        TestIndicatorRange.create!(
          test_indicator_id:,
          min_age: test_indicator_range[:age_min],
          max_age: test_indicator_range[:age_max],
          lower_range: test_indicator_range[:range_lower],
          upper_range: test_indicator_range[:range_upper],
          value: test_indicator_range[:value],
          interpretation: test_indicator_range[:interpretation]
        )
      end
    end

    def create_or_update_test_indicators(test_indicators)
      test_indicators.map do |item|
        begin
          # First, try to find the test indicator by various identifiers
          record = TestIndicator.find_by(nlims_code: item[:nlims_code]) if item[:nlims_code].present?
          record ||= TestIndicator.find_by(scientific_name: item[:scientific_name]) if item[:scientific_name].present?
          record ||= TestIndicator.find_by(name: item[:name])
          record ||= TestIndicator.find_by(name: item[:iblis_mapping_name]) if item[:iblis_mapping_name].present?

          if record.present?
            # Update existing record
            if record.new_record?
              record.name = item[:name]
              record.test_indicator_type = item[:measure_type][:name]
              record.unit = item[:unit] if item[:unit].present?
              record.save!
            end
            indicator = create_or_update_record(record, item)
          else
            # Check if there's any test indicator with the same name to avoid "name has already been taken" error
            if TestIndicator.exists?(name: item[:name])
              # Log that we're skipping this record due to duplicate name
              Rails.logger.info("Skipping test indicator creation - name '#{item[:name]}' already exists")
              # Return the existing record instead of creating a new one
              indicator = TestIndicator.find_by(name: item[:name])
            else
              # Create a new record if no duplicate exists
              record = TestIndicator.new
              record.name = item[:name]
              record.test_indicator_type = item[:measure_type][:name]
              record.unit = item[:unit] if item[:unit].present?
              record.save!
              indicator = create_or_update_record(record, item)
            end
          end

          # Create or update test indicator ranges if indicator was created/updated successfully
          create_or_update_test_indicator_ranges(item[:measure_ranges_attributes], indicator.id) if indicator.present? && item[:measure_ranges_attributes].present?
          indicator
        rescue ActiveRecord::RecordInvalid => e
          # Log the validation error but don't halt the process
          Rails.logger.error("Failed to create/update test indicator '#{item[:name]}': #{e.message}")
          # Return the existing record if possible
          TestIndicator.find_by(name: item[:name]) || nil
        end
      end
    end

    def create_or_update_test_types(test_types)
      test_types.each do |item|
        record = find_or_initialize_test_type(item)
        if record.new_record?
          record.name = item[:name]
          record.department = create_or_update_department(item[:test_category])
          record.sex = item[:can_be_done_on_sex] if item[:can_be_done_on_sex].present?
          record.save!
        end
        test_type = create_or_update_record(record, item)
        test_type.test_indicators = create_or_update_test_indicators(item[:measures])
        test_type.specimens = create_or_update_specimens(item[:specimen_types])
        test_type.organisms = create_or_update_organisms(item[:organisms])
        create_or_update_tat(test_type.id, item[:targetTAT])
        test_type.lab_test_sites = create_or_update_lab_test_sites(item[:lab_test_sites])
      end
    end

    def create_or_update_tat(test_type_id, tat)
      return if tat.nil?

      tat_value = tat.split(' ').first
      tat_unit = tat.split(' ').last
      return unless tat_value.present? && tat_unit.present?

      tat_unit == 'Hours' if tat_unit == 'hrs'
      tat_unit == 'Days' if tat_unit == 'days'
      tat_unit == 'Minutes' if tat_unit == 'mins'
      tat_record = ExpectedTat.find_by(test_type_id:)
      tat_record ||= ExpectedTat.new
      if tat_record.new_record?
        tat_record.value = tat_value
        tat_record.unit = tat_unit
        tat_record.test_type_id = test_type_id
        tat_record.save!
      else
        ExpectedTat.update!(tat_record.id, value: tat_value, unit: tat_unit)
      end
    end

    def create_or_update_lab_test_sites(lab_test_sites)
      lab_test_sites.map do |item|
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
    end

    def create_or_update_test_panels(test_panels)
      test_panels.each do |item|
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
        record.test_types = TestType.where(id: item.map { |tt| tt[:id] })
      end
    end

    def find_or_initialize_test_type(item)
      record = TestType.find_by(nlims_code: item[:nlims_code]) if item[:nlims_code].present?
      record ||= TestType.find_by(scientific_name: item[:scientific_name]) if item[:scientific_name].present?
      record ||= TestType.find_by(name: item[:name])
      record ||= TestType.find_by(name: item[:iblis_mapping_name]) if item[:iblis_mapping_name].present?
      record ||= TestType.new
      record
    end
  end
end
