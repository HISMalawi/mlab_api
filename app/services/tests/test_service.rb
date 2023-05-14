# frozen_string_literal: true

module Tests
  class TestService
    def find_tests(query, department_id = nil, test_status = nil, start_date = nil, end_date = nil)
      tests = Test.joins(:test_type, :current_test_status, order: [encounter: [client: [:person]]])
      if query.present?
        tests = tests.where('test_types.name LIKE ? or test_types.short_name LIKE ?', "%#{query}%",
                            "%#{query}%")
      end
      tests = search_by_accession_number(tests, query) if query.present?
      tests = search_by_tracking_number(tests, query) if query.present?
      tests = search_by_client(tests, query) if query.present?
      tests = search_by_test_status(tests, test_status) if test_status.present?
      if department_id.present? && is_not_reception?(department_id)
        tests = tests.where(test_type_id: TestType.where(department_id:).pluck(:id))
      end
      tests = filter_by_date(tests, start_date, end_date) if start_date.present?
      tests.order('orders.id DESC')
    end

    def client_report(client, from = Date.today, to = Date.today, order_id = nil)
      tests = Test.joins(:test_type, order: [encounter: [client: [:person]]])
                  .where(client: { id: client.id })

      tests = tests.where(orders: { id: order_id }) if order_id.present?

      tests = tests.where(encounter: { start_date: from..to }) if order_id.nil?

      tests.order('orders.id DESC')
      {
        person: client.person,
        tests: tests
      }
    end

    private

    def is_not_reception?(department_id)
      Department.find(department_id).name != 'Lab Reception'
    end

    def search_by_tracking_number(tests, query)
      tests.or(Test.where('orders.tracking_number LIKE ?', "%#{query}%"))
    end

    def search_by_accession_number(tests, query)
      tests.or(Test.where('orders.accession_number LIKE ?', "%#{query}%"))
    end

    def search_by_client(tests, query)
      clients = client_service.search_client(query, 1000)
      return tests unless clients.present?

      tests.or(Test.where('clients.id IN (?)', clients.map(&:id))) if clients.present?
    end

    def search_by_test_status(tests, query)
      tests.where('current_test_status.name = (?)', query.to_s)
    end

    def filter_by_date(tests, start_date, end_date)
      tests.where(created_date: Date.parse(start_date).beginning_of_day..Date.parse(end_date).end_of_day)
    end

    def client_service
      ClientManagement::ClientService
    end
  end
end
