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
          from ||= today
          to ||= today
          department_condition = build_department_condition(department)
          data = query_data(from, to, department_condition)
          {
            from:,
            to:,
            data: sanitize_data(data)
          }
        end

        def build_department_condition(department)
          return '' unless department.present? && department != 'All'

          department_id = Department.find_by(name: department)&.id
          " AND d.id = '#{department_id}'"
        end

        # rubocop:disable Metrics/MethodLength
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
        # rubocop:enable Metrics/MethodLength

        # rubocop:disable Metrics/MethodLength
        def sanitize_data(data)
          data.group_by { |item| item[:department] }.map do |department, items|
            tests = items.group_by { |item| item[:test_type] }.transform_values do |test_items|
              test_items.map do |item|
                associated_ids = DrilldownIdentifier.create(
                  id: SecureRandom.uuid,
                  data: { associated_ids: item[:associated_ids], department: }
                )
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
        # rubocop:enable Metrics/MethodLength
      end
    end
  end
end
