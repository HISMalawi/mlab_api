# frozen_string_literal: true

module Tests
  class TestService
    def find_tests(query, department_id = nil, test_status = nil, start_date = nil, end_date = Date.today, limit =  1000)
      if query.present?
        tests = Test.where(id: search_string_test_ids(query))
      else
        tests = Test.limit(limit).order('tests.created_date DESC')
      end
      tests = filter_by_date(tests, start_date, end_date) if start_date.present?
      if department_id.present? && is_not_reception?(department_id)
        tests = tests.where(test_type_id: TestType.where(department_id:).pluck(:id))
      end
      tests = search_by_test_status(tests, test_status) if test_status.present?
      tests.order('tests.created_date DESC')
    end

    def client_report(client, from = Date.today, to = Date.today, order_id = nil)
      orders = Order.joins(encounter: [client: [:person]]).where(client: {id: client.id}, id: order_id) if order_id.present?
      orders = Order.joins(encounter: [client: [:person]]).where(
        client: {id: client.id},
        encounter: { start_date: Date.parse(from).beginning_of_day..Date.parse(to).end_of_day }
        ) if (order_id.blank? && !from.blank?)
      orders = Order.joins(encounter: [client: [:person]]).where(
          client: {id: client.id}) if (order_id.blank? && from.blank?)
      person = client.person.as_json(only: %i[id first_name middle_name last_name sex date_of_birth birth_date_estimated])
      client_identifiers = ClientIdentifier.where(client_id: client.id)
      
      {
        client: {
          person: person,
          client_identifiers: client_identifiers
        },
        orders: orders.order(id: :desc)
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
      status = Status.find_by(name: query)
      test_statuses = TestStatus.where(status_id: status.id, test_id: tests.ids).group(:test_id)
        .select("test_id, MAX(created_date) created_date") unless status.nil?
      tests.where(id: test_statuses.pluck(:test_id))
    end

    def filter_by_date(tests, start_date, end_date)
      tests.where(created_date: Date.parse(start_date).beginning_of_day..Date.parse(end_date).end_of_day)
    end

    def search_string_test_ids(q_string)
      acc_number = GlobalService.current_location.code << q_string
      Test.find_by_sql("
        SELECT t.id FROM tests t WHERE t.order_id IN (SELECT o.id FROM orders o
        WHERE o.accession_number = '#{acc_number}' OR o.tracking_number = '#{q_string}')
        OR t.order_id IN (#{client_query(q_string)}) OR t.test_type_id IN
        (SELECT DISTINCT tt.id FROM test_types tt WHERE tt.name LIKE '%#{q_string}%')
        ORDER BY t.created_date DESC LIMIT 1000").pluck(:id)
    end

    def client_query(query)
      name = query.split(' ')
      first_name = name.first
      last_name = name.last
      "SELECT oo.id FROM orders oo WHERE oo.encounter_id IN (SELECT DISTINCT e.id FROM encounters e WHERE
        e.client_id IN ((SELECT DISTINCT c.id FROM clients c WHERE c.person_id IN (SELECT DISTINCT p.id FROM people p
          WHERE (p.first_name LIKE '%#{first_name}%' AND p.last_name LIKE '%#{last_name}%')
          OR (p.first_name LIKE '%#{first_name}%' AND p.last_name LIKE '%#{last_name}%') OR (
          CONCAT(p.first_name, p.middle_name, p.last_name) LIKE '%#{first_name}%'
        )))))"
    end

    def client_service
      ClientManagement::ClientService
    end
  end
end
