# frozen_string_literal: true

# Reports modules
module Reports
  # Aggregate report module
  module Aggregate
    # Department report class
    class DepartmentReport
      attr_accessor :from, :to, :department, :sql

      def initialize(from, to, department)
        @from = from
        @to = to
        @department = department
        @sql = <<-SQL
              SELECT
                rrd.test_type, rrd.ward, MONTHNAME(rrd.created_date) AS month, COUNT(DISTINCT  rrd.test_id) AS count#{' '}
              FROM
                report_raw_data rrd
              WHERE
                rrd.department = '#{department}'
                AND rrd.created_date BETWEEN '#{from}' AND '#{to}'
                AND rrd.status_id IN (4,5)
              GROUP BY  rrd.test_type, rrd.ward, MONTHNAME(rrd.created_date)
        SQL
      end

      def generalize_depart_report
        data = ReportRawData.find_by_sql(@sql)
        blood_bank_products = []
        critical_values = %w[Haematology Biochemistry Paediatric].include?(@department) ? department_critical_values : []
        {
          from:,
          to:,
          department:,
          wards: wards(data),
          data: serialize_generalize_depart_report(data),
          critical_values:,
          blood_bank_products:
        }
      end

      def blood_bank_product_report

      end

      def department_critical_values
        sql_query = <<-SQL
          SELECT
          rrd.test_indicator_name,
          rrd.ward,
          CASE
            WHEN ExtractNumberFromString(result) < tir.lower_range THEN 'Low'
            WHEN ExtractNumberFromString(result) > tir.upper_range THEN 'High'
            ELSE 'Normal'
          END AS critical_value_level,
          COUNT(DISTINCT rrd.test_id) AS count
        FROM
          report_raw_data rrd
        INNER JOIN test_indicator_ranges tir ON
          tir.test_indicator_id = rrd.test_indicator_id
        WHERE
          rrd.department = '#{department}'
          AND rrd.created_date BETWEEN '#{from}' AND '#{to}'
          AND rrd.status_id IN (4, 5)
          AND (rrd.result IS NOT NULL OR rrd.result <> 0)
        GROUP BY
          rrd.test_indicator_name,
          rrd.ward,
          CASE
            WHEN ExtractNumberFromString(result) < tir.lower_range THEN 'Low'
            WHEN ExtractNumberFromString(result) > tir.upper_range THEN 'High'
            ELSE 'Normal'
          END
        SQL
        data = ReportRawData.find_by_sql(sql_query)
        serialize_critical_values(data)
      end

      def serialize_generalize_depart_report(data)
        data.group_by { |entry| entry['month'].downcase }.map do |month, month_entries|
          {
            month.to_sym => month_entries.group_by do |entry|
                              entry['test_type'].downcase
                            end
                                         .map do |test_type, test_type_entries|
                              {
                                "test_type": test_type,
                                "ward": test_type_entries.map do |entry|
                                          { entry['ward'] => entry['count'] }
                                        end.reduce({}, :merge)
                              }
                            end
          }
        end
      end

      def serialize_critical_values(data)
        data.group_by { |entry| entry['test_indicator_name'].downcase }.map do |test_indicator_name, test_indicator_name_entries|
          {
            test_indicator_name.to_sym => test_indicator_name_entries.group_by do |entry|
                              entry['critical_value_level'].downcase
                            end
                                         .map do |test_type, test_type_entries|
                              {
                                "critical_value_level": test_type,
                                "ward": test_type_entries.map do |entry|
                                          { entry['ward'] => entry['count'] }
                                        end.reduce({}, :merge)
                              }
                            end
          }
        end
      end

      def wards(data)
        wards_ = data.map do |entry|
          entry['ward']
        end
        wards_.uniq.sort
      end
    end
  end
end
