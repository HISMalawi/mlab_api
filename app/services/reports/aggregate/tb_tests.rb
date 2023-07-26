module Reports
  module Aggregate
    class TbTests
      def generate_report(from: nil, to: nil)
        query = <<-SQL
        SELECT monthname(created_date) AS month,test_indicator_name, result,
        COUNT(DISTINCT test_id) AS count
        FROM `report_raw_data`
        WHERE department = 'Microbiology' and result is not null
        GROUP by monthname(created_date), result, test_indicator_name;
        SQL
        data = ReportRawData.find_by_sql(query)
      end
    end
  end
end
