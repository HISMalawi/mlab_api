# frozen_string_literal: true

# Test result model
class TestResult < VoidableRecord
  belongs_to :test
  belongs_to :test_indicator

  after_create :set_test_status_to_completed, :insert_record_into_moh_report_mat_view

  def set_test_status_to_completed
    TestStatus.find_or_create_by!(test_id: test.id, status_id: Status.find_by_name('completed').id)
  end

  def insert_record_into_moh_report_mat_view
    MohReportMatViewJob.perform_async(test.id, id)
  end
end
