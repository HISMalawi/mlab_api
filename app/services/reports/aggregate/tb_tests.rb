module Reports
  module Aggregate
    class TbTests
      def generate_report(from: nil, to: nil)
        query = <<-SQL
        SELECT
            ti.name AS test_indicator_name,
            MONTHNAME(t.created_date) AS month,
            tr.value AS result,
            COUNT(DISTINCT t.id) count,
            GROUP_CONCAT(DISTINCT t.id) AS associated_ids
        FROM
            tests t
                INNER JOIN
            test_types tt ON tt.id = t.test_type_id
                INNER JOIN
            test_type_indicator_mappings ttim ON ttim.test_types_id = tt.id
                INNER JOIN
            test_indicators ti ON ti.id = ttim.test_indicators_id
                INNER JOIN
            test_results tr ON tr.test_id = t.id
                AND ti.id = tr.test_indicator_id AND tr.voided = 0
        WHERE
            DATE(t.created_date) BETWEEN '#{from}' AND '#{to}'
                AND tt.id IN #{report_utils.test_type_ids('TB tests')}
                AND tr.value NOT IN ('' , '0', 'N/A')
        GROUP BY MONTHNAME(t.created_date) , result , test_indicator_name
        SQL
        data = Report.find_by_sql(query)
        months = []
        data.each do |entry|
          months << entry.month
        end
        {
          data: serialize_data(data),
          months: months.uniq
        }
      end

      def serialize_data(data)
        data.group_by { |entry| entry['test_indicator_name'].downcase }
            .transform_values do |test_indicator_name_entries|
          test_indicator_name_entries.group_by { |entry| entry['result'].downcase }
                                     .map do |result, result_entries|
            months = result_entries.each_with_object({}) do |entry, acc|
              month = entry['month']
              count = entry['count']
              associated_ids = UtilsService.insert_drilldown(entry, nil)

              acc[month] = {
                count:,
                associated_ids:
              }
            end

            {
              result:,
              month: months
            }
          end
        end
      end

      def report_utils
        Reports::Moh::ReportUtils
      end
    end
  end
end
