module TestCatalog::TestStatusesService 
  class << self 

    #updates test status (with reason)
    def update_test_status(test_status, status, reason=nil) 
      unless test_status.blank?
        new_test_status = TestStatus.new(
          test_id: test_status.test_id,
          status_id: status.id,
          creator: User.current.id, 
          status_reason_id: reason,
        )
        if new_test_status.save 
          new_test_status
        else
          new_test_status.errors
        end
      end 
    end

  end
end