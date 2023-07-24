module Reports
  module Aggregate
    class UserStatistic
      def generate_report(from: nil, to: nil, user: nil, report_type: nil, page: nil, limit: nil)
        data = {}
        if report_type == 'summary'
          data = get_summary(from:, to:, user:)
        elsif report_type == 'patients_registry'
          data = patients_registry(from:, to:, user:)
        elsif report_type == 'tests_registry'
          data = tests_registry(from:, to:, user:, page:, limit:)
        elsif report_type == 'specimen_registry'
          data = specimen_registry(from:, to:, user:)
        elsif report_type == 'tests_performed'
          data = tests_performed(from:, to:, user:)
        else
          raise ArgumentError, "Invalid report type, please specify"
        end
        data
      end

      private

      def get_summary(from: nil, to: nil, user: nil)
        users = user.nil? ? User.all : [User.find(user)]
        users_test_counts = users.map do |user|
          tests_completed = TestStatus.where('created_date >= ? AND created_date <= ?', from, to).where(creator: user.id, status_id: Status.find_by_name('completed').id).count
          tests_received = Test.joins(order: :order_statuses).where(order_statuses: { creator: user.id }).where('order_statuses.status_id = ?', Status.find_by_name('specimen-accepted').id).count
          specimen_collected = OrderStatus.where(creator: user.id, status_id: Status.find_by_name('pending').id).count
          specimen_rejected = OrderStatus.where(creator: user.id, status_id: Status.find_by_name('specimen-rejected').id).count
          tests_performed = TestStatus.where(creator: user.id, status_id: Status.find_by_name('verified').id).count
          tests_authorized = TestStatus.where(creator: user.id, status_id: Status.find_by_name('verified').id).count

          {
            user: user.username,
            tests_completed: tests_completed,
            tests_received: tests_received,
            specimen_collected: specimen_collected,
            specimen_rejected: specimen_rejected,
            tests_performed: tests_performed,
            tests_authorized: tests_authorized
          }
        end
        users_test_counts
      end

      def patients_registry(from: nil, to: nil, user: nil)
        if user.nil?
          clients = Client.includes(:person).all
        else
          clients = Client.includes(:person).where(creator: user)
        end
        user_patients = clients.map(&:person)
      end


      def specimen_registry(from: nil, to: nil, user: nil)
        users = user.nil? ? User.all : [User.find(user)]
        user_specimens = []

        # get acc n, specimen type, patient no, patient, reg date---> reportdataraw then filter bv user/creator
      end

      def tests_registry(from: nil, to: nil, user: nil, page: nil, limit: nil)
        users = user.nil? ? User.all : [User.find(user)]
        data = []
        users.each do |user|
          if user.nil?
            data = PaginationService.paginate(Test.all, page, limit)
          else
            data  = Test.where('creator', user).page(page).per(limit)
          end
        end
        { 'tests' => data, 'metadata' => PaginationService.pagination_metadata(data) }
      end

      def tests_performed(from: nil, to: nil, user: nil)
        users = user.nil? ? User.all : [User.find(user)]
        user_tests = {}
        users.each do |user|
          user_tests <<  ReportRawData.where('created_date >= ? AND created_date <= ?', from, to).where(status_creator: user.full_name, status_id: 4).select(
                  'test_id, test_type,  patient_no, patient_name, accession_number, created_date', 'id'
                ).distinct('test_id')
        end
        user_tests
      end
    end
  end
end
