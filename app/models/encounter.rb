class Encounter < VoidableRecord
  belongs_to :client
  belongs_to :facility, :class_name => 'Facility'
  belongs_to :destination, :class_name => 'Facility'
  belongs_to :facility_section
end
