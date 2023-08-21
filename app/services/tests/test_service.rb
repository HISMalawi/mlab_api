# frozen_string_literal: true

require 'bantu_soundex'

# Module for managing tests related activities such as search, client report based on the test
module Tests
  # Class for managing tests related activities
  class TestService
    def find_tests(query, department_id = nil, test_status = nil, start_date = nil, end_date = nil, limit = 1000)
      default = YAML.load_file("#{Rails.root}/config/application.yml")['default']
      tests = if query.present?
                use_elasticsearch = default.nil? ? false : default['use_elasticsearch']
                if use_elasticsearch
                  es = ElasticSearchService.new
                  if es.ping
                    Test.where(id: es.search(query))
                  else
                    Test.where(id: search_string_test_ids(query))
                  end
                else
                  Test.where(id: search_string_test_ids(query))
                end
              else
                Test.limit(limit).order('tests.created_date DESC')
              end
      tests = filter_by_date(tests, start_date, end_date) if start_date.present?
      if department_id.present? && not_reception?(department_id)
        tests = tests.where(test_type_id: TestType.where(department_id:).pluck(:id))
      end
      tests = search_by_test_status(tests, test_status) if test_status.present?
      tests.order('tests.created_date DESC')
    end

    def client_report(client, from = Date.today, to = Date.today, order_id = nil)
      if order_id.present?
        orders = Order.joins(encounter: [client: [:person]]).where(client: { id: client.id }, id: order_id)
      end
      if order_id.blank? && !from.blank?
        orders = Order.joins(encounter: [client: [:person]]).where(
          client: { id: client.id },
          encounter: { start_date: Date.parse(from).beginning_of_day..Date.parse(to).end_of_day }
        )
      end
      if order_id.blank? && from.blank?
        orders = Order.joins(encounter: [client: [:person]]).where(client: { id: client.id })
      end
      person = client.person.as_json(
        only: %i[id first_name middle_name last_name sex date_of_birth birth_date_estimated]
      )
      client_identifiers = ClientIdentifier.where(client_id: client.id)
      {
        client: {
          person:,
          client_identifiers:
        },
        orders: orders.order(id: :desc)
      }
    end

    def total_test_count(from, to, department)
      to = to.present? ? Date.parse(to) : Date.today
      from = from.present? ? Date.parse(from) : to - 30
      department_id = department.present? ? Department.find_by_name(department).id : Department.find_by_name('Lab Reception').id
      test_count = if department == 'Lab Reception'
                    Test.where(created_date: from.beginning_of_day..to.end_of_day).count
                  else
                    Test.joins(:test_type).where(test_type: {department_id: department_id}, created_date: from.beginning_of_day..to.end_of_day).count
                  end
      {
        from:,
        to:,
        data: test_count
      }
    end

    def test_statuses_count(from, to, department)
      to = to.present? ? Date.parse(to) : Date.today
      from = from.present? ? Date.parse(from) : to - 30
      department_id = department.present? ? Department.find_by_name(department).id : Department.find_by_name('Lab Reception').id
      statuses_count = {}
      sql = "SELECT COUNT(DISTINCT ts.id) AS count, s.name FROM test_statuses ts INNER JOIN ( SELECT test_id, MAX(created_date) created_date
        FROM test_statuses GROUP BY test_id) cs ON cs.test_id = ts.test_id AND cs.created_date = ts.created_date INNER JOIN tests t
        ON t.id = ts.test_id INNER JOIN test_types tt ON t.test_type_id = tt.id INNER JOIN statuses s ON s.id = ts.status_id
        WHERE tt.department_id = #{department_id} AND t.created_date BETWEEN '#{from.beginning_of_day.strftime('%Y-%m-%d %H:%M:%S')}'
        AND '#{to.end_of_day.strftime('%Y-%m-%d %H:%M:%S')}' GROUP BY s.name"
      statuses = Status.all
      test_statuses_counts = Status.find_by_sql(sql)
      statuses.each do |status|
        statuses_count[status.name] = 0
      end
      test_statuses_counts.each do |status_count|
        statuses_count[status_count[:name]] = status_count[:count]
      end
      statuses_count
    end

    private

    def not_reception?(department_id)
      Department.find(department_id).name != 'Lab Reception'
    end

    def search_by_test_status(tests, query)
      status = Status.find_by(name: query)
      Test.joins(:test_status)
          .where('test_statuses.created_date = (
            SELECT MAX(created_date)
            FROM test_statuses
            WHERE test_statuses.test_id = tests.id
            )')
          .where(test_statuses: { test_id: tests.pluck(:id) })
          .select('test_statuses.status_id, tests.*')
          .where(test_statuses: { status_id: status.id })
    end

    def filter_by_date(tests, start_date, end_date)
      end_date = end_date.present? ? end_date : Date.today.strftime('%Y-%m-%d')
      tests.where(created_date: Date.parse(start_date).beginning_of_day..Date.parse(end_date).end_of_day)
    end

    def search_string_test_ids(q_string)
      acc_number = GlobalService.current_location.code << q_string
      Test.find_by_sql("
        SELECT t.id FROM tests t WHERE t.order_id IN (SELECT o.id FROM orders o
        WHERE o.accession_number = '#{acc_number}' OR o.accession_number = '#{GlobalService.current_location.code}#{acc_number}'
        OR o.tracking_number = '#{q_string}')
        OR t.order_id IN (#{client_query(q_string)}) OR t.test_type_id IN
        (SELECT DISTINCT tt.id FROM test_types tt WHERE tt.name LIKE '%#{q_string}%')
        ORDER BY t.created_date DESC LIMIT 1000").pluck(:id)
    end

    def client_query(query)
      name = query.split(' ')
      first_name = name.first.soundex
      last_name = name.last.soundex
      "SELECT oo.id FROM orders oo WHERE oo.encounter_id IN (SELECT DISTINCT e.id FROM encounters e WHERE
        e.client_id IN ((SELECT DISTINCT c.id FROM clients c WHERE c.person_id IN (SELECT DISTINCT p.id FROM people p
          WHERE (p.first_name_soundex = '#{first_name}' AND p.last_name_soundex = '#{last_name}')
          OR (p.first_name_soundex = '#{last_name}' AND p.last_name_soundex = '#{first_name}') OR (
          CONCAT(p.first_name_soundex, p.last_name_soundex) = '#{first_name}'
        )))))"
    end
  end
end
