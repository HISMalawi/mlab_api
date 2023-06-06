# frozen_string_literal: true

require_relative 'sql_queries'

# Helper module that create migration helper functions
module MohReportDataMigrationHelpers
  include SqlQueries

  def create_moh_report_aggregate_data_procedure
    execute <<-SQL
      
      CREATE PROCEDURE populate_moh_report_aggregate_data()
      BEGIN
        DROP TABLE IF EXISTS moh_report_aggregate_data;
        CREATE TABLE moh_report_aggregate_data (
          created_date DATE,
          indicator VARCHAR(255),
          total INT,
          department VARCHAR(255)
        );

        INSERT INTO moh_report_aggregate_data
        (#{union_query});
          
        SELECT * FROM moh_report_aggregate_data;
      END
    SQL
  end

  def drop_report_data_procedure
    execute "DROP PROCEDURE IF EXISTS populate_moh_report_aggregate_data"
    execute "DROP TABLE IF EXISTS moh_report_aggregate_data"
  end

  def union_query
    indicator_queries = haematology_queries

    indicator_queries.join(' UNION ALL ')
  end
end