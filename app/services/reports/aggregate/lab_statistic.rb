# frozen_string_literal: true

# Reports module
module Reports
  # Aggregate reports module
  module Aggregate
    # LabStatistic reports module
    module LabStatistic
      class << self
        def generate_report(from: nil, to: nil, department: nil)
          today = Date.today.strftime('%Y-%m-%d')
          from = from.present? ? from : today
          to = to.present? ? to : today
          department = if department.present? && department != 'All'
                         " AND d.id =
          '#{Department.where(name: department).first&.id}'"
                       else
                         ''
                       end

          data = query_data(from, to, department)
          {
            from:,
            to:,
            data: sanitize_data(data)
          }
        end

        def get_details(from: nil, to: nil, department: nil, test_type: nil)
          today = Date.today.strftime('%Y-%m-%d')
          from = from.present? ? from : today
          to = to.present? ? to : today
          department = if department.present? && department != 'All'
            " AND d.id =
            '#{Department.where(name: department).first&.id}'"
          else
            ''
          end
          data = query_count_details(from, to, department, test_type)
        end

        def query_count_details(from, to, department, test_type)
          ReportRawData.find_by_sql(
            "SELECT
            p.first_name,
              p.last_name,
              p.sex,
              p.date_of_birth,
              o.accession_number,
            tt.name AS test_type,
              d.name as department,
            ss.name as status,
              tt.updated_date
          FROM
            tests t
              RIGHT JOIN
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
            test_types tt ON t.test_type_id = tt.id
              INNER JOIN
            departments d ON d.id = tt.department_id
              INNER JOIN
            test_statuses ts ON ts.test_id = t.id
              INNER JOIN
            statuses ss ON ss.id = ts.status_id
          WHERE
            DATE(t.created_date) BETWEEN '#{from}' AND '#{to}' #{department}
              AND tt.name = '#{test_type}'
              AND ts.status_id IN (4 , 5)"
          )
        end

        def query_data(from, to, department)
          ReportRawData.find_by_sql(
            "SELECT
                COUNT(DISTINCT t.id) AS total,
                MONTHNAME(t.created_date) AS month,
                tt.name AS test_type,
                d.name AS department
            FROM
                tests t
                    RIGHT JOIN
                test_types tt ON t.test_type_id = tt.id
                    INNER JOIN
                departments d ON d.id = tt.department_id
                    INNER JOIN
                test_statuses ts ON ts.test_id = t.id
            WHERE
                DATE(t.created_date) BETWEEN '#{from}' AND '#{to}' #{department}
                    AND ts.status_id IN (4 , 5)
            GROUP BY month , test_type , department"
          )
        end

        def sanitize_data(data)
          data.group_by { |item| item[:department] }.map do |depart, items|
            tests = items.group_by { |item| item[:test_type] }.transform_values do |test_items|
              test_items.map { |item| [item[:month], item[:total]] }.to_h
            end
            {
              depart => tests
            }
          end
        end
      end
    end
  end
end
