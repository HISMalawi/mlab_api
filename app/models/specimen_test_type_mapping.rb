class SpecimenTestTypeMapping < ApplicationRecord
  belongs_to :specimen
  belongs_to :test_type

  def void(void_reason)
    self.update(retired: 1, retired_date: Time.now, retired_by:  User.current.id, retired_reason: void_reason, updated_date: Time.now)
  end
end
