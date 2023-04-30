module EncounterTypeService
  class << self
    def create_encounter_type(encounter_type_params)
      ActiveRecord::Base.transaction do
        sections = encounter_type_params.delete(:facility_sections)
        encounter_type = EncounterType.create(encounter_type_params)
        s = sections.collect do |section|
          EncounterTypeFacilitySectionMapping.create(encounter_type: encounter_type, facility_section: FacilitySection.find(section))
        end
        { encounter_type: encounter_type, facility_sections: s}
    end
end

def update_encounter_type(encounter_type, encounter_type_params)
      ActiveRecord::Base.transaction do
        sections = encounter_type_params.delete(:facility_sections)
        encounter_type.update(encounter_type_params)
        new_mappings = sections.collect do |section|
            EncounterTypeFacilitySectionMapping.find_or_create_by(encounter_type: encounter_type, facility_section: FacilitySection.find(section))
        end
        prev_mappings = EncounterTypeFacilitySectionMapping.where(encounter_type: encounter_type).pluck(:facility_section_id)
        diff = prev_mappings - sections
        EncounterTypeFacilitySectionMapping.where(encounter_type: encounter_type, facility_section_id: diff).destroy_all
        new_mappings
        { encounter_type: encounter_type, facility_sections: new_mappings}
      end
    end
  end
end
