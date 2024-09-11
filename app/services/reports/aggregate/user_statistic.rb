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
          tests_completed = Report.find_by_sql(
            "SELECT COUNT(DISTINCT test_id) AS count, GROUP_CONCAT(DISTINCT test_id) AS associated_ids
             FROM test_statuses WHERE (DATE(created_date) BETWEEN '#{from.to_date}' AND '#{to.to_date}')
             AND creator = #{user_.id} AND status_id = #{tests_completed_status} GROUP BY creator"
          )&.first
          tests_completed = {
            count: tests_completed&.count || 0,
            associated_ids: UtilsService.insert_drilldown({ associated_ids: tests_completed&.associated_ids }, 'All')
          }
          tests_received = Report.find_by_sql(
            "SELECT COUNT(DISTINCT id) AS count, GROUP_CONCAT(DISTINCT id) AS associated_ids
             FROM tests WHERE (DATE(created_date) BETWEEN '#{from.to_date}' AND '#{to.to_date}')
             AND creator = #{user_.id} GROUP BY creator"
          )&.first
          tests_received = {
            count: tests_received&.count || 0,
            associated_ids: UtilsService.insert_drilldown({ associated_ids: tests_received&.associated_ids }, 'All')
          }
          specimen_collected = Report.find_by_sql(
            "SELECT COUNT(DISTINCT os.order_id) AS count, GROUP_CONCAT(DISTINCT t.id) AS associated_ids
             FROM order_statuses os INNER JOIN orders o ON o.id=os.order_id INNER JOIN tests t ON t.order_id = o.id
             WHERE (DATE(os.created_date) BETWEEN '#{from.to_date}' AND '#{to.to_date}') AND os.creator = #{user_.id}
             AND os.status_id = #{specimen_accepted} GROUP BY os.creator"
          )&.first
          specimen_collected = {
            count: specimen_collected&.count || 0,
            associated_ids: UtilsService.insert_drilldown({ associated_ids: specimen_collected&.associated_ids }, 'All')
          }
          specimen_rejected = Report.find_by_sql(
            "SELECT COUNT(DISTINCT os.order_id) AS count, GROUP_CONCAT(DISTINCT t.id) AS associated_ids
             FROM order_statuses os INNER JOIN orders o ON o.id=os.order_id INNER JOIN tests t ON t.order_id = o.id
             WHERE (DATE(os.created_date) BETWEEN '#{from.to_date}' AND '#{to.to_date}') AND os.creator = #{user_.id}
             AND os.status_id = #{specimen_rejected_status} GROUP BY os.creator"
          )&.first
          specimen_rejected = {
            count: specimen_rejected&.count || 0,
            associated_ids: UtilsService.insert_drilldown({ associated_ids: specimen_rejected&.associated_ids }, 'All')
          }
          tests_authorized = Report.find_by_sql(
            "SELECT COUNT(DISTINCT test_id) AS count, GROUP_CONCAT(DISTINCT test_id) AS associated_ids
             FROM test_statuses WHERE (DATE(created_date) BETWEEN '#{from.to_date}' AND '#{to.to_date}')
             AND creator = #{user_.id} AND status_id = #{test_verified} GROUP BY creator"
          )&.first
          tests_authorized = {
            count: tests_authorized&.count || 0,
            associated_ids: UtilsService.insert_drilldown({ associated_ids: tests_authorized&.associated_ids }, 'All')
          }
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
            clients.id AS patient_no, concat(people.first_name, " ", people.last_name) AS patient_name,
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
        tests = Test.joins(order: { encounter: { client: :person } })
                    .joins(:test_type, :test_status).where(
                      created_date: from.to_date.beginning_of_day..to.to_date.end_of_day
                    ).where(test_statuses: { status_id: [4,
                                                         5] }).select('DISTINCT orders.accession_number, test_types.name AS test_type,
          clients.id AS patient_no, concat(people.first_name, " ", people.last_name) AS patient_name,
          tests.created_date, tests.id AS test_id, tests.id')
        tests = tests.where(creator: user) unless user.nil?
        tests = PaginationService.paginate(tests, page:, limit:)
        { tests: tests.map(&:attributes), metadata: PaginationService.pagination_metadata(tests) }
      end
    end
  end
end
