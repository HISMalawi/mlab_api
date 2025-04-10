# frozen_string_literal: true

# Test result model
class TestResult < VoidableRecord
  belongs_to :test
  belongs_to :test_indicator

  after_create :set_test_status_to_completed

  def set_test_status_to_completed
    ActiveRecord::Base.transaction do
      test_id = test.id
      status_id = Status.find_by_name('completed')&.id
      v_status_id = Status.find_by_name('verified')&.id
      test_status = TestStatus.where(test_id:, status_id:).first
      if test_status.nil?
        TestStatus.create!(status_id:, test_id:)
      else
        test_status.update!(status_id:, updated_date: Time.now)
      end
      return if v_status_id == test.status_id

      test.update!(status_id:)
    end
  end
end
