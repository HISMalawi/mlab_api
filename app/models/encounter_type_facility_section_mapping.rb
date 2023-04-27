class EncounterTypeFacilitySectionMapping < ApplicationRecord
  validates_presence_of :facility_section_id
  validates_presence_of :encounter_type_id
end
