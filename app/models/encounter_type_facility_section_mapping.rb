class EncounterTypeFacilitySectionMapping < ApplicationRecord
    belongs_to :encounter_type
    belongs_to :facility_section
    validates_presence_of :facility_section_id
    validates_presence_of :encounter_type_id
end
