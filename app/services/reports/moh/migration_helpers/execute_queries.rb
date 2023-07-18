# frozen_string_literal: true

# reports module
module Reports
  # Moh reports module
  module Moh
    # Helper module for executing indicator counts
    module MigrationHelpers
      # Executes sql queries
      module ExecuteQueries
        include Reports::Moh::MigrationHelpers::SqlQueries

        def insert_into_moh_data_report_table(department:, action: 'init', time_filter: Date.today.to_s)
          queries = get_queries(department:, action:, time_filter:)
          queries = queries.join(' UNION ALL ')
          sql_query = "SELECT MONTHNAME(created_date) AS month, SUM(total) AS total, indicator FROM (#{queries}) AS moh
            GROUP BY MONTHNAME(created_date), indicator"
          ReportRawData.find_by_sql(sql_query)
          # records = ReportRawData.find_by_sql(queries)
          # return if records.empty?

          # MohReportDataMaterialized.upsert_all(records.map do |record|
          #                                        record.attributes.except('id')
          #                                      end, returning: false)
        end

        def insert_into_report_raw_data_table(test_id)
          ReportRawData.insert_data(test_id:)
        end
      end
    end
  end
end
