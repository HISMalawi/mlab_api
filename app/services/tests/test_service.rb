# frozen_string_literal: true

require 'bantu_soundex'

# Module for managing tests related activities such as search, client report based on the test
module Tests
  # Class for managing tests related activities
  class TestService
    # rubocop:disable Metrics/AbcSize
    # rubocop:disable Metrics/MethodLength
    def initialize(params = {})
      depart_id = params[:department_id]
      @query = params[:search]
      @department_id = depart_id.present? ? depart_id : Department.find_by(name: 'Lab Reception').id
      @test_status = params[:status]
      @start_date = params[:start_date]
      @end_date = params[:end_date]
      @facility_sections = params[:facility_sections].present? ? params[:facility_sections].split(',') : []
      @per_page = (params[:per_page] || 25).to_i
      @page = (params[:page] || 1).to_i
      @lab_location = params[:lab_location] || 1
      @use_elasticsearch = YAML.load_file(
        Rails.root.join('config/application.yml')
      )['default']&.fetch('use_elasticsearch', false)
    end
    # rubocop:enable Metrics/AbcSize
    # rubocop:enable Metrics/MethodLength

    def find_tests
      tests = if @query.present? || @facility_sections.present?
                @use_elasticsearch ? use_elasticsearch_search : use_native_search
              else
                Test.all
              end
      tests = filter_by_date(tests, @start_date, @end_date) if @start_date.present?
      tests = filter_by_lab_location(tests, @lab_location)
      if @department_id.present? && not_reception?(@department_id)
        tests = tests.where(test_type_id: TestType.where(department_id:).pluck(:id))
      end
      tests = search_by_test_status(tests, @test_status) if @test_status.present?
      tests_ = tests
      tests = tests.order('tests.id DESC').page(@page).per(@per_page + 1)
      tests = tests_.order('tests.id DESC').limit(@per_page) if tests.empty? && @query.present?
      records = Report.find_by_sql(query(process_ids(tests.pluck('id'))))
      {
        data: serialize_tests(records),
        meta: {
          current_page: @page,
          next_page: records.count > @per_page ? @page + 1 : @page,
          prev_page: @page - 1,
          total_pages: records.count > @per_page ? @page + 1 : @page,
          total_count: records.count > @per_page ? @per_page * (@page + 1) : ((@per_page * (@page - 1)) + records.count)
        }
      }
    end

    def find(test_id)
      record = Report.find_by_sql(query(process_ids([test_id]))).first
      raise 'Could not find test record' if record.nil?

      serialize_test(record, is_test_list: false)
    end

    def serialize_tests(records, is_test_list: true, is_client_report: false)
      data = []
      records.each do |record|
        data.push(serialize_test(record, is_test_list:, is_client_report:))
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
          c.id AS patient_no,
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
          sp.id AS specimen_id,
          t.lab_location_id
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
          LEFT JOIN
      encounter_types et ON e.encounter_type_id = et.id AND et.voided = 0
          LEFT JOIN
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
      where_c = "o.id = #{order_id}"
      c_join = ' INNER JOIN clients c ON c.id = e.client_id AND c.voided = 0'
      if order_id.present?
        c_join = ''
      elsif order_id.blank? && from.blank?
        where_c = "c.id = #{client}"
      elsif order_id.blank? && !from.blank?
        where_c = "o.created_date BETWEEN '#{Date.parse(from).beginning_of_day}'
          AND '#{Date.parse(to).end_of_day}' AND c.id = #{client}"
      end
      orders = Order.find_by_sql("
      SELECT
          o.id,
          o.encounter_id,
          pr.name AS priority,
          o.accession_number,
          o.tracking_number,
          o.sample_collected_time,
          o.created_date,
          et.name AS request_origin,
          fs.name AS requesting_ward,
          o.requested_by,
          ost.name AS o_status
      FROM
          orders o
              INNER JOIN
          encounters e ON e.id = o.encounter_id AND e.voided = 0
              LEFT JOIN
          encounter_types et ON e.encounter_type_id = et.id
              AND et.voided = 0
            #{c_join}  INNER JOIN
          priorities pr ON pr.id = o.priority_id
              LEFT JOIN
          facility_sections fs ON fs.id = e.facility_section_id
              INNER JOIN
          statuses ost ON ost.id = o.status_id
      WHERE
        #{where_c} ORDER BY o.id DESC
      ")
      orders_serializer(orders, client)
    end

    private

    def use_elasticsearch_search
      es = ElasticSearchService.new
      if es.ping && !archive_department?(@department_id)
        Test.where(id: es.search(@query, @facility_sections))
      else
        use_native_search
      end
    end

    def use_native_search
      Test.where(id: search_string_test_ids)
    end

    def not_reception?(department_id)
      Department.find(department_id).name != 'Lab Reception' && !archive_department?(department_id)
    end

    def archive_department?(department_id)
      Department.find(department_id).name == 'Archives'
    end

    def search_by_test_status(tests, status)
      status_id = Status.find_by(name: status)&.id
      status_id ||= Status.find_by(name: 'test-rejected')&.id if status.downcase == 'rejected'
      tests.where(status_id:)
    end

    def filter_by_date(tests, start_date, end_date)
      end_date = end_date.present? ? end_date : Date.today.strftime('%Y-%m-%d')
      tests.where('created_date >= ? AND created_date <= ?', start_date.to_date.beginning_of_day,
                  end_date.to_date.end_of_day)
    end

    def filter_by_lab_location(tests, lab_location_id)
      tests.where(lab_location_id:)
    end

    # rubocop:disable Metrics/MethodLength
    def search_string_test_ids
      return Test.where("tests.voided= 0 #{facility_section_condition}").pluck(:id) unless @query.present?

      acc_number = GlobalService.current_location.code << @query
      Test.find_by_sql(
        "SELECT tests.id FROM tests t WHERE (tests.order_id IN (
          SELECT o.id FROM orders o
            WHERE o.accession_number = '#{@query}'
              OR o.accession_number = '#{acc_number}'
              OR o.tracking_number = '#{@query}'
          )
          OR tests.order_id IN (#{client_query(@query)})
          OR tests.test_type_id IN (SELECT DISTINCT tt.id FROM test_types tt WHERE tt.name LIKE '%#{@query}%'))
          #{facility_section_condition}
        ORDER BY tests.id DESC LIMIT 1000"
      ).pluck(:id)
    end
    # rubocop:enable Metrics/MethodLength

    def facility_section_condition
      return '' unless @facility_sections.present?

      f_section_ids = FacilitySection.where(name: @facility_sections)&.ids
      f_section_join = "(#{f_section_ids.join(', ')})"
      " AND tests.order_id IN (SELECT eeo.id FROM orders eeo INNER JOIN encounters e ON e.id = eeo.encounter_id
        AND e.voided = 0 AND e.facility_section_id IN #{f_section_join})"
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

    def test_indicators(test_id, test_type_id, sex, dob)
      json_response = []
      test_type = TestType.find(test_type_id)
      fbc_format = Tests::FormatService.fbc_format
      records = TestIndicator.find_by_sql("
                  SELECT
                    ti.id, ti.name, ti.test_indicator_type,
                    ti.unit, ti.description, tr.id AS result_id,
                    tr.value, tr.result_date, tr.machine_name
                  FROM test_indicators ti
                  INNER JOIN
                    test_type_indicator_mappings ttim ON ttim.test_indicators_id = ti.id
                  LEFT JOIN test_results tr ON ti.id = tr.test_indicator_id
                    AND ti.retired = 0 AND tr.voided = 0 AND tr.test_id = #{test_id}
                  WHERE ttim.test_types_id = #{test_type_id}")
      records.each do |record|
        if test_type.name.include?('FBC')
          fbc_format[record['name'].upcase.to_sym] = test_indicator_seriliazer(record, sex, dob)
        else
          json_response << test_indicator_seriliazer(record, sex, dob)
        end
      end
      json_response = Tests::FormatService.to_array(fbc_format) if test_type.name.include?('FBC')
      json_response
    end

    def test_indicator_seriliazer(test_indicator, sex, dob)
      {
        id: test_indicator['id'],
        name: test_indicator['name'],
        test_indicator_type: test_indicator['test_indicator_type'],
        unit: test_indicator['unit'],
        description: test_indicator['description'],
        result: result_seriliazer(
          test_indicator['result_id'],
          test_indicator['value'],
          test_indicator['result_date'],
          test_indicator['machine_name']
        ),
        indicator_ranges: indicator_ranges(test_indicator['id'], test_indicator['test_indicator_type'], sex, dob)
      }
    end

    # Add x to the indicator unit to separate result and unit for nummeric unit
    def add_x_to_test_indicator_unit(unit)
      return unit if unit.nil? || unit.blank?

      unit = remove_leading_asterisk(unit)
      return unit unless starts_with_number?(unit)

      "x#{unit}"
    end

    def starts_with_number?(string)
      !!(string =~ /^\d/)
    end

    def remove_leading_asterisk(string)
      string = string.strip
      string.start_with?('*') ? string[1..] : string
    end

    def result_seriliazer(id, value, result_date, machine_name)
      return {} if id.nil?

      { id:, value:, result_date:, machine_name: }
    end

    def indicator_ranges(test_indicator_id, test_indicator_type, sex, dob)
      age = calculate_age(dob)
      sex = full_sex(sex)
      ranges = TestIndicatorRange.where(test_indicator_id:)
      if test_indicator_type&.downcase == 'numeric'
        ranges = ranges.where("#{age} BETWEEN min_age AND max_age AND (sex = '#{sex}' OR sex = 'both')")
      end
      unique_ranges = ranges.uniq { |range| [range.test_indicator_id, range.value] }
      unique_ranges.map do |range|
        map_indicator_range(range)
      end
    end

    # rubocop:disable Metrics/MethodLength
    def map_indicator_range(range)
      {
        id: range.id,
        test_indicator_id: range.test_indicator_id,
        sex: range.sex,
        min_age: range.min_age,
        max_age: range.max_age,
        lower_range: range.lower_range,
        upper_range: range.upper_range,
        interpretation: range.interpretation,
        value: range.value
      }
    end
    # rubocop:enable Metrics/MethodLength

    def full_sex(sex)
      sex.downcase == 'f' ? 'Female' : 'Male'
    end

    def calculate_age(dob)
      today = Date.today
      years_difference = today.year - dob.year
      years_difference -= 1 if (today.month < dob.month) || (today.month == dob.month && today.day < dob.day)
      years_difference += 1 if years_difference.zero?
      years_difference
    end

    def expected_tat(test_type_id)
      ExpectedTat.where(test_type_id:).select('id, test_type_id, value, unit').first
    end

    # rubocop:disable Metrics/MethodLength
    def test_status_trail(test_id)
      records = TestStatus.find_by_sql("
        SELECT
          ts.id,
          ts.test_id AS record_id,
          ts.status_id,
          ts.created_date,
          s.id AS s_id,
          s.name AS s_name,
          u.username,
          p.first_name,
          p.last_name,
          sr.id AS sr_id,
          sr.description
        FROM
          test_statuses ts
              INNER JOIN
          statuses s ON s.id = ts.status_id
              INNER JOIN
          users u ON u.id = ts.creator
              INNER JOIN
          people p ON p.id = u.person_id
              LEFT JOIN
          status_reasons sr ON sr.id = ts.status_reason_id
        WHERE
          ts.test_id = #{test_id}
      ")
      status_trail_serializer(records)
    end
    # rubocop:enable Metrics/MethodLength

    # rubocop:disable Metrics/MethodLength
    def order_status_trail(order_id)
      records = OrderStatus.find_by_sql("
        SELECT
          os.id,
          os.order_id AS record_id,
          os.status_id,
          os.created_date,
          s.id AS s_id,
          s.name AS s_name,
          u.username,
          p.first_name,
          p.last_name,
          sr.id AS sr_id,
          sr.description
        FROM
          order_statuses os
              INNER JOIN
          statuses s ON s.id = os.status_id
              INNER JOIN
          users u ON u.id = os.updated_by
              INNER JOIN
          people p ON p.id = u.person_id
              LEFT JOIN
          status_reasons sr ON sr.id = os.status_reason_id
        WHERE
          os.order_id = #{order_id}
      ")
      status_trail_serializer(records)
    end
    # rubocop:enable Metrics/MethodLength

    def status_change_initiator(record)
      {
        username: record['username'],
        first_name: record['first_name'],
        last_name: record['last_name']
      }
    end

    def status_serializer(record)
      {
        id: record['s_id'],
        name: record['s_name']
      }
    end

    def status_reason_serializer(record)
      return {} if record['sr_id'].nil?

      { id: record['sr_id'], description: record['description'] }
    end

    def client_serializer(record)
      {
        id: record['patient_no'],
        first_name: record['first_name'],
        middle_name: record['middle_name'].present? || record['middle_name']&.downcase == 'unknown' ? record['middle_name'] : '',
        last_name: record['last_name'],
        sex: record['sex'],
        date_of_birth: record['date_of_birth'],
        birth_date_estimated: record['birth_date_estimated']
      }
    end

    # rubocop:disable Metrics/MethodLength
    def status_trail_serializer(records)
      json_response = []
      records.each do |record|
        json_response << {
          id: record['id'],
          test_id: record['record_id'],
          status_id: record['status_id'],
          created_date: record['created_date'],
          status: status_serializer(record),
          initiator: status_change_initiator(record),
          status_reason: status_reason_serializer(record)
        }
      end
      json_response
    end
    # rubocop:enable Metrics/MethodLength

    def suscept_test_result(test_id)
      Tests::CultureSensivityService.get_drug_susceptibility_test_results(test_id)
    end

    def culture_observation(test_id)
      Tests::CultureSensivityService.culture_observation(test_id)
    end

    def orders_serializer(records, client_id)
      client_record = client(client_id)
      orders = []
      records.each do |record|
        tests = Test.where(order_id: record['id']).order(id: :desc)
        orders << order_serializer(record, tests)
      end
      {
        client: {
          person: client_serializer(client_record),
          client_identifiers: []
        },
        orders:
      }
    end

    def client(id)
      Client.joins(:person).where(id:).select('
        clients.id AS patient_no, first_name, middle_name, last_name, sex, date_of_birth, birth_date_estimated
      ').first
    end

    def print_count(order_id)
      ClientOrderPrintTrail.where(order_id:).count
    end

    def specimen(id)
      Specimen.where(id:).first&.name
    end

    def test_types(id)
      test_types = TestType.joins(:department).where(id:).select('test_types.name, departments.name AS department, print_device')
      test_types.map do |type|
        {
          name: type['name'],
          department: type['department'],
          print_device: type['print_device']
        }
      end
    end

    def order_serializer(record, tests)
      {
        id: record['id'],
        encounter_id: record['encounter_id'],
        priority: record['priority'],
        accession_number: record['accession_number'],
        tracking_number: record['tracking_number'],
        requested_by: record['requested_by'],
        collected_by: '',
        sample_collection_time: record['sample_collected_time'],
        created_date: record['created_date'],
        request_origin: record['request_origin'],
        requesting_ward: record['requesting_ward'],
        order_status: record['o_status'],
        specimen: specimen(tests.first.specimen_id),
        order_status_trail: order_status_trail(record['id']),
        test_types: test_types(tests.pluck('test_type_id')),
        tests: serialize_tests(
          Report.find_by_sql(query(process_ids(tests.pluck('id')))), is_test_list: false, is_client_report: true
        ),
        print_count: print_count(record['id'])
      }
    end

    def rejection_reason(test_id, order_id)
      status_ids = Status.where(name: %w[test-rejected rejected voided not-done])&.ids
      status_reason = TestStatus.find_by(test_id:, status_id: status_ids)
      status_reason ||= OrderStatus.find_by(order_id:, status_id: Status.find_by_name('specimen-rejected')&.id)
      StatusReason.find_by(id: status_reason&.status_reason_id)&.description || ''
    end

    def serialize_test(record, is_test_list: true, is_client_report: false)
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
        requested_by: record['requested_by'],
        completed_by: record['t_status'] == 'completed' && is_client_report == false ? completed_by(record['id']) : {},
        client: client_serializer(record),
        status: record['t_status'],
        order_status: record['o_status'],
        lab_location: LabLocation.where(id: record['lab_location_id']).first
      }
      return json if is_test_list

      if %w[test-rejected rejected not-done voided].include?(record['t_status'].downcase)
        json[:rejection_reason] = rejection_reason(record['id'], record['order_id'])
      end

      json[:is_machine_oriented] = machine_oriented?(record['test_type_id']) unless is_client_report
      json[:result_remarks] = Remark.where(tests_id: record['id']).first
      json[:indicators] = test_indicators(record['id'], record['test_type_id'], record['sex'], record['date_of_birth'])
      json[:expected_turn_around_time] = expected_tat(record['test_type_id']) unless is_client_report
      json[:status_trail] = test_status_trail(record['id'])
      json[:order_status_trail] = order_status_trail(record['order_id']) unless is_client_report
      json[:suscept_test_result] = suscept_test_result(record['id'])
      json[:culture_observation] = culture_observation(record['id']) unless is_client_report
      json
    end
  end
end
