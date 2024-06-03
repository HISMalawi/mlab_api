# frozen_string_literal: true

# Home dashboard analytics service
module HomeDashboardService
  class << self
    def test_catalog
      data = {
        organisms: Organism.count,
        drugs: Drug.count,
        diseases: Disease.count,
        test_panels: TestPanel.count,
        test_types: TestType.active_without_paediatric_cancer.count,
        specimen_types: Specimen.count,
        lab_sections: Department.count
      }
      home_dashboard_reports('test_catalog', data, nil, 1)
    end

    def lab_configuration
      data = {
        instruments: Instrument.count,
        facilities: Facility.count,
        visit_types: EncounterType.count,
        wards: FacilitySection.count,
        printers: Printer.all.select('id', 'name', 'description')
      }
      home_dashboard_reports('lab_config', data, nil, 1)
    end

    def clients_by_sex(lab_location_id)
      by_sex = Report.find_by_sql("
        SELECT
          COUNT(DISTINCT c.id) AS count, p.sex
        FROM
          clients c
        INNER JOIN
          people p ON p.id = c.person_id AND c.voided = 0
        AND p.voided = 0
        WHERE c.lab_location_id = #{lab_location_id}
          GROUP BY p.sex
        ")
      count = { 'F' => 0, 'M' => 0 }
      by_sex.each do |sex|
        count[sex['sex']] = sex['count']
      end
      count
    end

    def clients(lab_location_id)
      data = {
        clients: Client.where(lab_location_id:).count,
        by_sex: clients_by_sex(lab_location_id)
      }
      home_dashboard_reports('clients', data, nil, lab_location_id)
    end

    def tests(from, to, department, lab_location)
      data = {
        from:,
        to:,
        tests: total_test_count(from, to, department, lab_location),
        tests_by_status: test_statuses_count(from, to, department, lab_location)
      }
      home_dashboard_reports('tests', data, department, lab_location)
    end

    def total_test_count(from, to, department, lab_location_id)
      lab_location_id ||= 1
      department_id = department_id(department)
      test_types_ids = lab_location_test_types(department_id, lab_location_id)
      test_count = if department == 'All'
                     Report.find_by_sql("
                      SELECT
                        COUNT(DISTINCT t.id) AS count
                      FROM tests t
                      WHERE t.voided = 0 AND DATE(t.created_date) BETWEEN '#{from}' AND '#{to}'
                      AND t.lab_location_id = #{lab_location_id}")
                   else
                     Report.find_by_sql("
                      SELECT
                          COUNT(DISTINCT t.id) AS count
                      FROM
                        tests t
                      INNER JOIN
                        test_types tt ON tt.retired = 0 AND tt.id = t.test_type_id
                      WHERE
                          t.voided = 0
                        AND t.test_type_id IN #{test_types_ids}
                        AND DATE(t.created_date) BETWEEN '#{from}' AND '#{to}'
                        AND t.lab_location_id = #{lab_location_id}
                     ")
                   end
      test_count.first&.count
    end

    def lab_location_test_types(department_id, lab_location_id)
      test_types = TestType.where(department_id:).pluck(:name)
      test_types_ids = []
      if lab_location_id == 3
        d_id = Department.unscoped.where("name like '%paed%'").first&.id
        paeds_test_types = TestType.where(department_id: d_id).pluck(:name)
        paeds_items = paeds_test_types.select do |item|
          test_types.any? { |prefix| item.downcase.start_with?("#{prefix.downcase} (paeds)") }
        end
        test_types_ids = TestType.where(name: paeds_items).pluck(:id)
      elsif lab_location_id == 2
        d_id = Department.unscoped.where("name like '%cancer%'").first&.id
        paeds_test_types = TestType.where(department_id: d_id).pluck(:name)
        paeds_items = paeds_test_types.select do |item|
          test_types.any? { |prefix| item.downcase.start_with?("#{prefix.downcase} (cancercenter)") }
        end
        test_types_ids = TestType.where(name: paeds_items).pluck(:id)
      else
        test_types_ids = TestType.where(name: test_types).pluck(:id)
      end
      return "('unknow_or_empty')" if test_types_ids.empty?

      "(#{test_types_ids.join(', ')})"
    end

    def department_id(department)
      dpt = Department.find_by_name(department)&.id
      dpt || 0
      dpt
    end

    def test_statuses_count(from, to, department, lab_location_id)
      lab_location_id ||= 1
      department_id = department_id(department)
      test_types_ids = lab_location_test_types(department_id, lab_location_id)
      statuses_count = Report.find_by_sql("
          SELECT
            COUNT('DISTINCT t.id') AS  count, s.name
          FROM
              tests t
          INNER JOIN statuses s ON s.id = t.status_id
          WHERE
            t.voided = 0 AND t.test_type_id IN #{test_types_ids}
          AND DATE(t.created_date) BETWEEN '#{from}' AND '#{to}'
          AND t.lab_location_id = #{lab_location_id}
          GROUP BY s.id
      ")
      result_hash = { 'verified' => 0, 'started' => 0, 'pending' => 0, 'rejected' => 0, 'voided' => 0,
                      'completed' => 0 }
      statuses_count.each do |entry|
        result_hash[entry['name']] = entry['count']
      end
      result_hash
    end

    def home_dashboard_reports(report_type, data, department, lab_location_id)
      department = 'All' if department.nil? || department == 'Lab Reception'
      HomeDashboard.find_or_create_by!(report_type:, department:, lab_location_id:).update(data:)
    end
  end
end
