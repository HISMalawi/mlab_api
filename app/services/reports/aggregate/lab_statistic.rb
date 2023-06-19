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
          department = department.present? ? " AND department = '#{department}'" : ''
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
              department,
              test_type,
              COUNT(DISTINCT(test_id)) AS total,
              MONTHNAME(created_date) AS month
            FROM
              report_raw_data
            WHERE created_date BETWEEN '#{from}' AND '#{to}' #{department}
            GROUP BY department , test_type , MONTHNAME(created_date)"
          )
        end

        def sanitize_data(data)
          result = data.group_by { |item| item[:department] }.map do |depart, items|
            tests = items.group_by { |item| item[:test_type] }.transform_values do |test_items|
              test_items.map { |item| [item[:month], item[:total]] }.to_h
            end
          
            {
              depart => tests
            }
          end
          result
        end
      end
    end
  end
end
