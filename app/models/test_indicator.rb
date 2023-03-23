class TestIndicator < ApplicationRecord
  belongs_to :test_type
  enum test_indicator_type: [:auto_complete, :free_text, :numeric, :alpa_numeric]

  def void(void_reason)
    self.update(retired: 1, retired_date: Time.now, retired_by:  User.current.id, retired_reason: void_reason, updated_date: Time.now)
  end
end
