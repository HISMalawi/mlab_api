class CreateRefreshMaterializedViewMohReportEvent < ActiveRecord::Migration[7.0]
  def up
    execute <<-SQL
      CREATE EVENT refresh_materialized_moh_report_data
      ON SCHEDULE EVERY 1 MINUTE
      COMMENT 'Refreshes the materialized moh report data'
      DO
        REPLACE INTO moh_report_data_materialized
        SELECT FLOOR(RAND() * 10000000) AS id, created_date, indicator, total, department
        FROM moh_report_data;
    SQL
  end

  def down
    execute 'DROP EVENT IF EXISTS refresh_materialized_moh_report_data;'
  end
end
