class EncounterType < VoidableRecord
  self.primary_key = 'id'
  validates :name, presence: true, uniqueness: true
  has_many :encounter_type_facility_section_mappings
  has_many :facility_sections, through: :encounter_type_facility_section_mappings

  def as_json(options = {})
    super(options.merge({only: %i[id name description created_date updated_date]}, methods: :facility_sections))
  end
end
