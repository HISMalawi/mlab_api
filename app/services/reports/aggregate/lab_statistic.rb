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
