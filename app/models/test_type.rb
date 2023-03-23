class TestType < ApplicationRecord
  belongs_to :department
  
  def void(void_reason)
    self.update(retired: 1, retired_date: Time.now, retired_by:  User.current.id, retired_reason: void_reason, updated_date: Time.now)
  end
end
