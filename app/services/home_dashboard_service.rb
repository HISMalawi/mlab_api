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
      home_dashboard_reports('test_catalog', data, nil)
    end

    def lab_configuration
      data = {
        instruments: Instrument.count,
        facilities: Facility.count,
        visit_types: EncounterType.count,
        wards: FacilitySection.count,
        printers: Printer.all.select('id', 'name', 'description')
      }
      home_dashboard_reports('lab_config', data, nil)
    end

    def clients_by_sex
      by_sex = Report.find_by_sql("
        SELECT
          COUNT(DISTINCT c.id) AS count, p.sex
        FROM
          clients c
        INNER JOIN
          people p ON p.id = c.person_id AND c.voided = 0
        AND p.voided = 0
          GROUP BY p.sex
        ")
      count = { 'F' => 0, 'M' => 0 }
      by_sex.each do |sex|
        count[sex['sex']] = sex['count']
      end
      count
    end

    def clients
      data = {
        clients: Client.count,
        by_sex: clients_by_sex
      }
      home_dashboard_reports('clients', data, nil)
    end

    def tests(from, to, department)
      data = {
        tests: total_test_count(from, to, department),
        tests_by_status: test_statuses_count(from, to, department)
      }
      home_dashboard_reports('tests', data, department)
    end

    def total_test_count(from, to, department)
      test_count = if department == 'All'
                     Report.find_by_sql("
                      SELECT
                        COUNT(DISTINCT t.id) AS count
                      FROM tests t
                      WHERE t.voided = 0 AND t.created_date BETWEEN '#{from}' AND '#{to}'")
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
                        AND tt.department_id = #{Department.find_by_name(department)&.id}
                        AND t.created_date BETWEEN '#{from}' AND '#{to}'
                     ")
                   end
      test_count.first&.count
    end

    def test_statuses_count(from, to, department)
      department_id = if department == 'All'
                        0
                      else
                        Department.find_by_name(department).id
                      end
      statuses_count = Report.find_by_sql("
          SELECT
            COUNT('DISTINCT t.id') AS  count, s.name
          FROM
              tests t
          INNER JOIN
              test_types tt ON tt.retired = 0 AND tt.id = t.test_type_id
          INNER JOIN statuses s ON s.id = t.status_id
          WHERE
              t.voided = 0
          AND tt.department_id = #{department_id}
          AND t.created_date BETWEEN '#{from}' AND '#{to}'
          GROUP BY s.id
      ")
      result_hash = { 'verified' => 0, 'started' => 0, 'pending' => 0, 'rejected' => 0, 'voided' => 0,
                      'completed' => 0 }
      statuses_count.each do |entry|
        result_hash[entry['name']] = entry['count']
      end
      result_hash
    end

    def home_dashboard_reports(report_type, data, department)
      department = 'All' if department.nil? || department == 'Lab Reception'
      HomeDashboard.find_or_create_by!(report_type:, department:).update(data:)
    end
  end
end
