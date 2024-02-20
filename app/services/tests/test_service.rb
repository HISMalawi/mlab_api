# frozen_string_literal: true

require 'bantu_soundex'

# Module for managing tests related activities such as search, client report based on the test
module Tests
  # Class for managing tests related activities
  class TestService
    def find_tests(query, department_id = nil, test_status = nil, start_date = nil, end_date = nil, per_page, page)
      per_page ||= 25
      page ||= 1
      default = YAML.load_file("#{Rails.root}/config/application.yml")['default']
      tests = if query.present?
                use_elasticsearch = default.nil? ? false : default['use_elasticsearch']
                if use_elasticsearch
                  es = ElasticSearchService.new
                  if archive_department?(department_id)
                    Test.where(id: search_string_test_ids(query))
                  elsif es.ping
                    Test.where(id: es.search(query))
                  else
                    Test.where(id: search_string_test_ids(query))
                  end
                else
                  Test.where(id: search_string_test_ids(query))
                end
              else
                Test.all
              end
      tests = filter_by_date(tests, start_date, end_date) if start_date.present?
      if department_id.present? && not_reception?(department_id)
        tests = tests.where(test_type_id: TestType.where(department_id:).pluck(:id))
      end
      tests = search_by_test_status(tests, test_status) if test_status.present?
      tests_ = tests
      tests = tests_.order('tests.id DESC').page(page).per(per_page.to_i + 1)
      tests = tests_.order('tests.id DESC').limit(per_page) if tests.nil? && query.present?
      records = Report.find_by_sql(query(process_ids(tests.pluck('id'))))
      {
        data: serialize_tests(records),
        meta: {
          current_page: page,
          next_page: records.count > per_page.to_i ? page.to_i + 1 : page,
          prev_page: page.to_i - 1,
          total_pages: records.count > per_page.to_i ? page.to_i + 1 : page,
          total_count: records.count > per_page.to_i ? per_page.to_i * (page.to_i + 1) : ((per_page.to_i * (page.to_i - 1)) + records.count)
        }
      }
    end

    def serialize_tests(records)
      data = []
      records.each do |record|
        data.push(serialize_test(record, true))
      end
      data
    end

    def process_ids(ids)
      ids.empty? ? "('unknown')" : "(#{ids.join(', ')})"
    end

    def query(tests_ids)
      "SELECT
      t.id,
      t.order_id,
      t.voided,
      t.test_type_id,
      p.id AS patient_no,
      p.first_name,
      p.middle_name,
      p.last_name,
      p.sex,
      o.requested_by,
      p.date_of_birth,
      p.birth_date_estimated,
      o.id AS order_id,
      o.accession_number,
      o.tracking_number,
      et.name AS request_origin,
      t.created_date,
      t.test_panel_id,
      tp.name AS test_panel_name,
      tt.name AS test_type,
      fs.name AS requesting_ward,
	    ost.id AS o_status_id,
	    ost.name AS o_status,
      tst.id AS t_status_id,
      tst.name AS t_status,
      sp.name AS specimen,
      sp.id AS specimen_id
        FROM
      tests t
          INNER JOIN
      test_types tt ON tt.id = t.test_type_id
          AND tt.retired = 0
          INNER JOIN
      specimen sp ON t.specimen_id = sp.id AND sp.retired = 0
          INNER JOIN
      orders o ON t.order_id = o.id AND o.voided = 0
          AND t.voided = 0
          INNER JOIN
      encounters e ON e.id = o.encounter_id AND e.voided = 0
          INNER JOIN
      encounter_types et ON e.encounter_type_id = et.id AND et.voided = 0
          INNER JOIN
      facility_sections fs ON fs.id = e.facility_section_id
          INNER JOIN
      clients c ON c.id = e.client_id AND c.voided = 0
          INNER JOIN
      people p ON p.id = c.person_id AND p.voided = 0
          LEFT JOIN
      test_panels tp ON tp.id = t.test_panel_id AND tp.retired = 0
          INNER JOIN
      statuses tst ON tst.id = t.status_id
		      INNER JOIN
	    statuses ost ON ost.id = o.status_id
        WHERE t.id IS NOT NULL AND t.id IN #{tests_ids} ORDER BY t.id DESC"
    end

    def completed_by(test_id)
      status_id = Status.where(name: 'completed').first&.id
      test_status_trail = TestStatus.find_by_sql("
        SELECT
            u.id, u.username, status_id
        FROM
            test_statuses ts
                INNER JOIN
            users u ON u.id = ts.creator
        WHERE
            ts.status_id = #{status_id} AND ts.test_id = #{test_id} LIMIT 1
      ")
      response = {}
      unless test_status_trail.empty?
        trail = test_status_trail[0]
        response[:id] = trail['id']
        response[:username] = trail['username']
        response[:is_super_admin] = super_admin?(trail['id'])
        response[:status_id] = trail['status_id']
      end
      response
    end

    def super_admin?(user_id)
      roles = UserRoleMapping.joins(:role).where(user_id:).pluck('roles.name')
      (roles.map!(&:downcase) & %w[superuser superadmin]).any?
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
                     Test.joins(:test_type).where(test_type: { department_id: },
                                                  created_date: from.beginning_of_day..to.end_of_day).count
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
      Department.find(department_id).name != 'Lab Reception' && !archive_department?(department_id)
    end

    def archive_department?(department_id)
      Department.find(department_id).name == 'Archives'
    end

    def search_by_test_status(tests, status)
      status_id = Status.find_by(name: status).id
      tests.where(status_id:)
    end

    def filter_by_date(tests, start_date, end_date)
      end_date = end_date.present? ? end_date : Date.today.strftime('%Y-%m-%d')
      tests.where('created_date >= ? AND created_date <= ?', start_date.to_date.beginning_of_day,
                  end_date.to_date.end_of_day)
    end

    def search_string_test_ids(q_string)
      acc_number = GlobalService.current_location.code << q_string
      Test.find_by_sql("
        SELECT t.id FROM tests t WHERE t.order_id IN (SELECT o.id FROM orders o
        WHERE o.accession_number = '#{acc_number}' OR o.accession_number = '#{GlobalService.current_location.code}#{acc_number}'
        OR o.tracking_number = '#{q_string}')
        OR t.order_id IN (#{client_query(q_string)}) OR t.test_type_id IN
        (SELECT DISTINCT tt.id FROM test_types tt WHERE tt.name LIKE '%#{q_string}%')
        ORDER BY t.id DESC LIMIT 1000").pluck(:id)
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

    def machine_oriented?(test_type_id)
      !InstrumentTestTypeMapping.where(test_type_id:).empty?
    end

    def test_indicators(test_id, test_type_id)
      json_response = []
      records = TestIndicator.find_by_sql("
                  SELECT
                    ti.id, ti.name, ti.test_indicator_type,
                    ti.unit, ti.description, tr.id AS result_id,
                    tr.value, tr.result_date, tr.machine_name
                  FROM test_indicators ti LEFT JOIN test_results tr ON ti.id = tr.test_indicator_id
                    AND ti.retired = 0 AND tr.voided = 0 AND tr.test_id = #{test_id}
                  WHERE ti.test_type_id = #{test_type_id}")
      records.each do |record|
        json_response << {
          id: record['id'],
          name: record['name'],
          test_indicator_type: indicator_type(record['test_indicator_type']),
          unit: record['unit'],
          description: record['description'],
          result: {
            id: record['result_id'],
            value: record['value'],
            result_date: record['result_date'],
            machine_name: record['machine_name']
          },
          indicator_ranges: indicator_ranges(record['id'])
        }
      end
      json_response
    end

    def indicator_type(value)
      TestIndicator.test_indicator_types.key(value)
    end

    def indicator_ranges(test_indicator_id)
      TestIndicatorRange.where(test_indicator_id:).select("
        id, test_indicator_id, min_age, max_age, lower_range, upper_range,
        interpretation, value
      ")
    end

    def serialize_test(record, is_test_list)
      json = {
        id: record['id'],
        order_id: record['order_id'],
        specimen_id: record['specimen_id'],
        specimen_type: record['specimen'],
        test_panel_id: record['test_panel_id'],
        test_panel_name: record['test_panel_name'],
        created_date: record['created_date'],
        request_origin: record['request_origin'],
        requesting_ward: record['requesting_ward'],
        accession_number: record['accession_number'],
        test_type_id: record['test_type_id'],
        test_type_name: record['test_type'],
        tracking_number: record['tracking_number'],
        voided: record['voided'],
        request_by: record['requested_by'],
        completed_by: completed_by(record['id']),
        client: {
          id: record['patient_no'],
          first_name: record['first_name'],
          middle_name: record['middle_name'].present? || record['middle_name']&.downcase == 'unknown' ? record['middle_name'] : '',
          last_name: record['last_name'],
          sex: record['sex'],
          date_of_birth: record['date_of_birth'],
          birth_date_estimated: record['birth_date_estimated']
        },
        status: record['t_status'],
        order_status: record['o_status']
      }
      return json if is_test_list

      json[:is_machine_oriented] = machine_oriented?(record['test_type_id'])
      json[:test_indicators] = test_indicators(record['id'], record['test_type_id'])
      json
    end
  end
end
