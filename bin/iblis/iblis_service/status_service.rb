Rails.logger = Logger.new(STDOUT)
module IblisService
  module StatusService
    class << self
      def create_test_status
        iblis_test_statuses = Iblis.find_by_sql("SELECT * FROM test_statuses")
        iblis_test_statuses.each do |status|
          Rails.logger.info("=========Creating Status: #{status.name}===========")
          Status.find_or_create_by!(name: status.name, retired: 0, creator: 1)
        end

        iblis_specimen_status = Iblis.find_by_sql("SELECT * FROM specimen_statuses")
        iblis_specimen_status.each do |status| 
          Rails.logger.info("=========Creating Order Status: #{status.name}===========")
          Status.find_or_create_by!(name: status.name, retired: 0, creator: 1)
        end
      end

      def create_test_status_reason
        iblis_rejection_reasons = Iblis.find_by_sql("SELECT * FROM rejection_reasons")
        iblis_rejection_reasons.each do |reason|
          Rails.logger.info("=========Creating status reason: #{reason.reason}===========")
          begin
            StatusReason.create!(description: reason.reason, retired: 0, creator: 1, created_date: Time.now, updated_date: Time.now)
          rescue => exception
            puts "skipping status reason already exists"
          end
        end
        iblis_not_done_reasons = Iblis.find_by_sql("SELECT * FROM not_done_reasons")
        iblis_not_done_reasons.each do |reason|
          Rails.logger.info("=========Creating status reason: #{reason.reason}===========")
          begin
            StatusReason.create!(description: reason.reason, retired: 0, creator: 1, created_date: Time.now, updated_date: Time.now)
          rescue => exception
            puts "skipping status reason already exists"
          end
        end
      end
    end 
  end
end
