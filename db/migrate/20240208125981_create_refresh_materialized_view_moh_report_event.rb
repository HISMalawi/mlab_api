# frozen_string_literal: true

# Migration for creating table refresher schedule
class CreateRefreshMaterializedViewMohReportEvent < ActiveRecord::Migration[7.0]
  def up
    execute <<-SQL
      CREATE EVENT refresh_materialized_moh_report_data
      ON SCHEDULE EVERY 1 MINUTE
      COMMENT 'Refreshes the materialized moh report data'
      DO
        BEGIN
          DELETE FROM moh_report_data_materialized;
          INSERT INTO moh_report_data_materialized (created_date, indicator, total, department)
          SELECT created_date, indicator, total, department
          FROM moh_report_data;
        END
    SQL
  end

  def down
    execute 'DROP EVENT IF EXISTS refresh_materialized_moh_report_data;'
  end
end
