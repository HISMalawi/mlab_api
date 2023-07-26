module Reports
  module Aggregate
    class TbTests
      def generate_report(from: nil, to: nil)
        grouped_data = {}
        query = <<-SQL
        SELECT monthname(created_date) AS month,test_indicator_name, result,
        COUNT(DISTINCT test_id) AS count
        FROM `report_raw_data`
        WHERE department = 'Microbiology' and created_date BETWEEN '#{from}' AND '#{to}' and result is not null
        GROUP by monthname(created_date), result, test_indicator_name;
        SQL

        # Use find_by_sql to execute the SQL query and get the data as an array of objects
        data = ReportRawData.find_by_sql(query)
        months = []
        data.each do |entry|
          months << entry.month
        end
        # grouped_data
        {
          data: serialize_data(data),
          months: months.uniq
      }
    end
      def serialize_data(data)
        data.group_by { |entry| entry['test_indicator_name'].downcase }.map do |test_indicator_name, test_indicator_name_entries|
          {
            test_indicator_name.to_sym => test_indicator_name_entries.group_by do |entry|
                              entry['result'].downcase
                            end
                                         .map do |result, result_entries|
                              {
                                "result": result,
                                "month": result_entries.map do |entry|
                                          { entry['month'] => entry['count'] }
                                        end.reduce({}, :merge)
                              }
                            end
          }
        end
      end
    end
  end
end
