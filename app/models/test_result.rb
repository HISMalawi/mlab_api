class TestResult < VoidableRecord
  belongs_to :test
  belongs_to :test_indicator

  validates_uniqueness_of :test_id
end
