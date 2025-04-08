# frozen_string_literal: true

class TestIndicator < RetirableRecord
  belongs_to :test_type, optional: true
  enum test_indicator_type: %i[auto_complete free_text numeric alpha_numeric rich_text]
  has_many :test_indicator_ranges
  has_many :test_type_test_indicators, dependent: :destroy, foreign_key: 'test_indicators_id'
end
