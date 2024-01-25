module Reports
  module Aggregate
    class UserStatistic
      def generate_report(from: nil, to: nil, user: nil, report_type: nil, page: nil, limit: nil)
        data = {}
        if report_type == 'summary'
          data = get_summary(from:, to:, user:, page:, limit:)
        elsif report_type == 'patients registry'
          data = patients_registry(from:, to:, user:, page:, limit:)
        elsif report_type == 'tests registry'
          data = tests_registry(from:, to:, user:, page:, limit:)
        elsif report_type == 'specimen registry'
          data = specimen_registry(from:, to:, user:, page:, limit:)
        elsif report_type == 'tests performed'
          data = tests_performed(from:, to:, user:, page:, limit:)
        else
          raise ArgumentError, 'Invalid report type, please specify'
        end
        data
      end

      private

      def get_summary(from: nil, to: nil, user: nil, page: nil, limit: nil)
        users = PaginationService.paginate(user.nil? ? User.all : User.where(id: user), page:, limit:)
        data = []
        specimen_accepted = Status.find_by_name('specimen-accepted').id
        tests_completed_status = Status.find_by_name('completed').id
        specimen_rejected_status = Status.find_by_name('specimen-rejected').id
        test_verified = Status.find_by_name('verified').id
        users.each do |user_|
          tests_completed = TestStatus.where(
            created_date: from.to_date.beginning_of_day..to.to_date.end_of_day,
            creator: user_.id,
            status_id: tests_completed_status
          ).count('DISTINCT test_id')
          tests_received = Test.where(
            created_date: from.to_date.beginning_of_day..to.to_date.end_of_day,
            creator: user_.id
          ).count('DISTINCT tests.id')
          specimen_collected = OrderStatus.where(
            created_date: from.to_date.beginning_of_day..to.to_date.end_of_day,
            creator: user_.id,
            status_id: specimen_accepted
          ).count('DISTINCT order_id')
          specimen_rejected = OrderStatus.where(
            created_date: from.to_date.beginning_of_day..to.to_date.end_of_day,
            creator: user_.id,
            status_id: specimen_rejected_status
          ).count('DISTINCT order_id')
          tests_authorized = TestStatus.where(
            created_date: from.to_date.beginning_of_day..to.to_date.end_of_day,
            creator: user_.id,
            status_id: test_verified
          ).count('DISTINCT test_id')
          data << {
            user: "#{user_.person.first_name.capitalize} #{user_.person.last_name.capitalize}",
            tests_completed:,
            tests_received:,
            specimen_collected:,
            specimen_rejected:,
            tests_authorized:
          }
        end
        { tests: data, metadata: PaginationService.pagination_metadata(users) }
      end

      def patients_registry(from: nil, to: nil, user: nil, page: nil, limit: nil)
        clients = Client.includes(:person).where(
          created_date: from.to_date.beginning_of_day..to.to_date.end_of_day
        )
        clients = clients.where(creator: user) unless user.nil?
        clients = PaginationService.paginate(clients, page:, limit:)
        { tests: clients.map(&:person), metadata: PaginationService.pagination_metadata(clients) }
      end

      def specimen_registry(from: nil, to: nil, user: nil, page: nil, limit: nil)
        records = Test.joins(order: { encounter: { client: :person } })
                      .joins(:specimen).where(
                        created_date: from.to_date.beginning_of_day..to.to_date.end_of_day
                      ).select('DISTINCT orders.accession_number, specimen.name AS specimen,
            clients.id AS patient_no, concat(people.first_name, people.last_name) AS patient_name,
            orders.created_date, orders.id').order('orders.created_date')
        records = records.where(creator: user) unless user.nil?
        records = PaginationService.paginate(records, page:, limit:)
        { 'tests' => records.map(&:attributes), 'metadata' => PaginationService.pagination_metadata(records) }
      end

      def tests_registry(from: nil, to: nil, user: nil, page: nil, limit: nil)
        data = PaginationService.paginate(Test.where(
                                            created_date: from.to_date.beginning_of_day..to.to_date.end_of_day
                                          ), page:, limit:)
        data = data.where(creator: user) unless user.nil?
        {
          tests: data,
          metadata: PaginationService.pagination_metadata(data)
        }
      end

      def tests_performed(from: nil, to: nil, user: nil, page: nil, limit: nil)
        users = user.nil? ? User.all : [User.find(user)]
        data = []
        users_ = []
        tests = []
        users.each do |user|
          users_ << user.full_name
        end
        data = ReportRawData.where('created_date >= ? AND created_date <= ?', from, to).where(status_creator: users_, status_id: 4).select(
          'test_id, test_type,  patient_no, patient_name, accession_number, created_date', 'id'
        ).distinct('test_id')
        tests = PaginationService.paginate(data, page:, limit:)
        { tests:, metadata: data.empty? ? data : PaginationService.pagination_metadata(tests) }
      end
    end
  end
end
