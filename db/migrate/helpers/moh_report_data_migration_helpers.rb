# frozen_string_literal: true

require_relative 'haematology/sql_queries'

# Helper module that create migration helper functions
module MohReportDataMigrationHelpers
  include Haematology::SqlQueries
  def create_moh_report_data_view
    execute <<-SQL
      CREATE OR REPLACE VIEW moh_report_data AS
      #{union_query}
    SQL
  end

  def drop_report_data_view
    execute 'DROP VIEW IF EXISTS moh_report_data'
  end

  def union_query
    indicator_queries = haematology_queries

    indicator_queries.join(' UNION ALL ')
  end
end
