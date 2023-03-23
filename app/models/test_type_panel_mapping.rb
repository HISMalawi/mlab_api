class TestTypePanelMapping < ApplicationRecord
  belongs_to :test_type
  belongs_to :test_panel

  def void(void_reason)
    self.update(voided: 1, voided_date: Time.now, voided_by:  User.current.id, voided_reason: void_reason, updated_date: Time.now)
  end
end
