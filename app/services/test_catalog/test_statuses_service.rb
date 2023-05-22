module TestCatalog::TestStatusesService
  class << self

    #updates test status (with reason)
    def update_test_status(test_status, status, reason=nil, person_talked_to=nil)
      unless test_status.blank?
        void_results(test_status, reason) if status.name == 'test-rejected'
        new_test_status = TestStatus.find_or_create_by!(
          test_id: test_status.test_id,
          status_id: status.id
        )
        new_test_status.update!(
          status_reason_id: reason,
          person_talked_to: person_talked_to
        )
      end
    end

    # Void results for test rejected action on test with status completed
    def void_results(test_status, reason)
      last_test_status = TestStatus.where(test_id: test_status.test_id)&.last&.status&.name
      if last_test_status == 'completed'
        test_results = TestResult.where(test_id: test_status.test_id)
        test_results.each do |test_result|
          test_result.void("test was rejected due to #{reason}")
        end
      end
    end

  end
end
