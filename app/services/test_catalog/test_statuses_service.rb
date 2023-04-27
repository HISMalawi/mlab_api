module TestCatalog::TestStatusesService 
  class << self 

    #updates test status (with reason)
    def update_test_status(test_status, test_status_params) 
      unless test_status.blank?
        new_test_status = TestStatus.new(test_status_params)
        if new_test_status.save 
          new_test_status
        else
          new_test_status.errors
        end
      end 
    end

  end
end