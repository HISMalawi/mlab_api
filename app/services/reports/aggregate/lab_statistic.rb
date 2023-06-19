# frozen_string_literal: true

# Reports module
module Reports
  # Aggregate reports module
  module Aggregate
    # LabStatistic reports module
    module LabStatistic
      class << self
        def generate_report(from: Date.today.strftime('%Y-%m-%d'), to: Date.today.strftime('%Y-%m-%d'), department: nil)
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
              COUNT(*) AS total,
              MONTHNAME(created_date) AS month
            FROM
              report_raw_data
            WHERE created_date BETWEEN '#{from}' AND '#{to}' #{department}
            GROUP BY department , test_type , MONTHNAME(created_date)"
          )
        end

        def sanitize_data(data)
          data.group_by { |item| item[:department] }.map do |department, items|
            key = items.first[:test_type]
            value = items.map { |item| [item[:month], item[:total]] }.to_h

            {
              department:,
              key.to_sym => value
            }
          end
        end
      end
    end
  end
end
