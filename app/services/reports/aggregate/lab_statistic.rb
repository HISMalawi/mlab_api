# frozen_string_literal: true

# Reports module
module Reports
  # Aggregate reports module
  module Aggregate
    # LabStatistic reports module
    module LabStatistic
      class << self
        def generate_report(from: nil, to: nil, department: nil, drilldown_identifier: nil)
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
            data: sanitize_data(data:, drilldown_identifier:)
          }
        end

        def query_count_details(associated_ids)
          Report.find_by_sql(
            "SELECT
              distinct t.id,
              p.first_name,
              p.last_name,
              p.sex,
              p.date_of_birth,
              o.accession_number,
              tt.name AS test_type,
              d.name AS department,
              tt.updated_date
            FROM
              tests t
              RIGHT JOIN orders o ON t.order_id = o.id AND o.voided = 0 AND t.voided = 0
              INNER JOIN encounters e ON e.id = o.encounter_id AND e.voided = 0
              LEFT JOIN encounter_types et ON e.encounter_type_id = et.id AND et.voided = 0
              LEFT JOIN facility_sections fs ON fs.id = e.facility_section_id
              INNER JOIN clients c ON c.id = e.client_id AND c.voided = 0
              INNER JOIN people p ON p.id = c.person_id AND p.voided = 0
              LEFT JOIN test_types tt ON t.test_type_id = tt.id
              INNER JOIN departments d ON d.id = tt.department_id
            WHERE t.id IN (#{DrilldownIdentifier.find(associated_ids).data['associated_ids']}) AND t.status_id IN (4, 5)
            "
          )
        end

        def query_data(from, to, department)
          ActiveRecord::Base.connection.execute('SET SESSION group_concat_max_len = 1000000')
          Report.find_by_sql(
            "SELECT
                COUNT(DISTINCT t.id) AS total,
                GROUP_CONCAT(DISTINCT t.id) AS associated_ids,
                MONTHNAME(t.created_date) AS month,
                tt.name AS test_type,
                d.name AS department
            FROM
                tests t
                    INNER JOIN
                test_types tt ON t.test_type_id = tt.id
                    INNER JOIN
                departments d ON d.id = tt.department_id
            WHERE
                DATE(t.created_date) BETWEEN '#{from}' AND '#{to}' #{department}
                    AND t.status_id IN (4 , 5)
            GROUP BY month , test_type , department;
            "
          )
        end

        def sanitize_data(data: nil, drilldown_identifier: nil)
          id = drilldown_identifier.nil? ? SecureRandom.uuid : drilldown_identifier
          data.group_by { |item| item[:department] }.map do |department, items|
            tests = items.group_by { |item| item[:test_type] }.transform_values do |test_items|
              test_items.map do |item|
                associated_ids = DrilldownIdentifier.find_or_create_by(id:)
                associated_ids.update(data: { associated_ids: item[:associated_ids], department: })
                [item[:month],
                 {
                   total: item[:total],
                   associated_ids: associated_ids.id
                 }]
              end.to_h
            end
            { department => tests }
          end
        end
      end
    end
  end
end
