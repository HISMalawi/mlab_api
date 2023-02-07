class TestResult < ApplicationRecord
  belongs_to :test
  belongs_to :test_indicator
end
