Rails.logger = Logger.new(STDOUT)
module TestCatalog
  module IblisData
    module StatusService
      class << self
        def create_test_status
          iblis_test_statuses = Iblis.find_by_sql("SELECT * FROM test_statuses")
          iblis_test_statuses.each do |status|
            Rails.logger.info("=========Creating Status: #{status.name}===========")
            Status.create(name: status.name, retired: 0, creator: 1, created_date: Time.now, updated_date: Time.now)
          end
        end

        def create_test_status_reason
          iblis_rejection_reasons = Iblis.find_by_sql("SELECT * FROM rejection_reasons")
          iblis_rejection_reasons.each do |reason|
            Rails.logger.info("=========Creating status reason: #{reason.reason}===========")
            StatusReason.create(description: reason.reason, retired: 0, creator: 1, created_date: Time.now, updated_date: Time.now)
          end
          iblis_not_done_reasons = Iblis.find_by_sql("SELECT * FROM not_done_reasons")
          iblis_not_done_reasons.each do |reason|
            Rails.logger.info("=========Creating status reason: #{reason.reason}===========")
            StatusReason.create(description: reason.reason, retired: 0, creator: 1, created_date: Time.now, updated_date: Time.now)
          end
        end
      end 
    end
  end
end