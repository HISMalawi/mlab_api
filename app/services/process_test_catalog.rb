# frozen_string_literal: true

# module ProcessTestCatalog
module ProcessTestCatalog
  class << self
    def check_new_version(current_version); end

    def get_test_catalog(_version)
      RestClient
    end

    def process_test_catalog(test_catalog)
      test_catalog.each do |test_type|
      end
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
        record = Drug.find_by(nlims_code: item[:nlims_code]) if item[:nlims_code].present?
        record ||= Drug.find_by(scientific_name: item[:scientific_name]) if item[:scientific_name].present?
        record ||= Drug.find_by(name: item[:name])
        record ||= Drug.new
        create_or_update_record(record, item)
      end
    end

    def create_or_update_organisms(organisms)
      organisms.map do |item|
        record = Organism.find_by(nlims_code: item[:nlims_code]) if item[:nlims_code].present?
        record ||= Organism.find_by(scientific_name: item[:scientific_name]) if item[:scientific_name].present?
        record ||= Organism.find_by(name: item[:name])
        record ||= Organism.new
        record = create_or_update_record(record, item)
        record.drugs = create_or_update_drugs(item[:drugs])
        record
      end
    end

    def create_or_update_specimens(specimens)
      specimens.map do |item|
        record = Specimen.find_by(nlims_code: item[:nlims_code]) if item[:nlims_code].present?
        record ||= Specimen.find_by(scientific_name: item[:scientific_name]) if item[:scientific_name].present?
        record ||= Specimen.find_by(name: item[:name])
        record ||= Specimen.new
        create_or_update_record(record, item)
      end
    end

    def create_or_update_department(item)
      record = Department.find_by(nlims_code: item[:nlims_code]) if item[:nlims_code].present?
      record ||= Department.find_by(scientific_name: item[:scientific_name]) if item[:scientific_name].present?
      record ||= Department.find_by(name: item[:name])
      record ||= Department.new
      create_or_update_record(record, item)
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
        record = TestIndicator.find_by(nlims_code: item[:nlims_code]) if item[:nlims_code].present?
        record ||= TestIndicator.find_by(scientific_name: item[:scientific_name]) if item[:scientific_name].present?
        record ||= TestIndicator.find_by(name: item[:name])
        record ||= TestIndicator.new
        if record.new_record?
          record.name = item[:name]
          record.test_indicator_type = item[:measure_type][:name]
          record.unit = item[:unit] if item[:unit].present?
          record.save!
        end
        indicator = create_or_update_record(record, item)
        create_or_update_test_indicator_ranges(item[:measure_ranges_attributes], indicator.id)
        indicator
      end
    end

    def create_or_update_test_types(test_types)
      test_types.each do |item|
        record = TestType.find_by(nlims_code: item[:nlims_code]) if item[:nlims_code].present?
        record ||= TestType.find_by(scientific_name: item[:scientific_name]) if item[:scientific_name].present?
        record ||= TestType.find_by(name: item[:name])
        record ||= TestType.new
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

    def create_or_update_test_panels(test_panels); end
  end
end
