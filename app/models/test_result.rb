class TestResult < VoidableRecord
  belongs_to :test
  belongs_to :test_indicator

  after_create :set_test_status_to_completed

  def set_test_status_to_completed
    TestStatus.create!(test_id: test.id, status_id: Status.find_by_name('completed').id, creator: User.current.id)
  end
end
