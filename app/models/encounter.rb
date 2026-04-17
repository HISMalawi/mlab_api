class Encounter < VoidableRecord
  belongs_to :client
  belongs_to :facility, class_name: 'Facility'
  belongs_to :destination, class_name: 'Facility'
  belongs_to :facility_section
  has_many :ward_change_trails, dependent: :destroy

  # Track previous facility_section_id for audit trail
  attr_accessor :current_user_id

  before_update :track_ward_change, if: :facility_section_id_changed?

  def as_json(options = {})
    super(options).merge({
                           client: client.person,
                           ward_change_trail: ward_change_trails.order(changed_at: :desc).as_json
                         }).as_json
  end

  private

  def track_ward_change
    return unless facility_section_id_changed?

    # Get the user ID from the current context or use creator as fallback
    user_id = current_user_id || User.current&.id || creator
    return unless user_id

    ward_change_trails.build(
      previous_facility_section_id: facility_section_id_was,
      new_facility_section_id: facility_section_id,
      changed_by: user_id,
      changed_by_name: User.find_by(id: user_id)&.username,
      changed_at: Time.current,
      creator: user_id,
      created_date: Time.current,
      updated_date: Time.current
    )
  end
end
