# frozen_string_literal: true

# Model to track ward/facility section changes for encounters
class WardChangeTrail < VoidableRecord
  belongs_to :encounter
  belongs_to :previous_facility_section, class_name: 'FacilitySection', optional: true
  belongs_to :new_facility_section, class_name: 'FacilitySection'
  belongs_to :changer, class_name: 'User', foreign_key: 'changed_by'

  validates :encounter_id, presence: true
  validates :new_facility_section_id, presence: true
  validates :changed_by, presence: true
  validates :changed_at, presence: true

  # Default scope to exclude voided records
  default_scope { where(voided: 0) }

  # Serialize the trail entry with ward details
  def as_json(options = {})
    super(options).merge({
                           previous_ward: previous_facility_section&.as_json(only: %i[id name]),
                           new_ward: new_facility_section&.as_json(only: %i[id name]),
                           changed_by_user: changer&.as_json(only: %i[id first_name last_name username]),
                           changed_at: changed_at
                         })
  end
end
