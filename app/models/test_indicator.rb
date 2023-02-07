class TestIndicator < ApplicationRecord
  belongs_to :test_type
  enum test_indicator_type: [:auto_complete, :free_text, :numeric, :alpa_numeric]
end
