# frozen_string_literal: true

class TestIndicator < RetirableRecord
  belongs_to :test_type
  enum test_indicator_type: [:auto_complete, :free_text, :numeric, :alpha_numeric]
end
