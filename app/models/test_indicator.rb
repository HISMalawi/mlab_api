# frozen_string_literal: true

class TestIndicator < RetirableRecord
  belongs_to :test_type, optional: true
  enum test_indicator_type: [:auto_complete, :free_text, :numeric, :alpha_numeric, :rich_text]
  has_many :test_indicator_ranges
end
