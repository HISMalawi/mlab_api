class ChangeResultColumnTypeInReportDataToText < ActiveRecord::Migration[7.0]
  def change
    change_column :report_raw_data, :result, :text
  end
end
