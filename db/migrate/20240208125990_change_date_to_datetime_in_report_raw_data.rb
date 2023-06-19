class ChangeDateToDatetimeInReportRawData < ActiveRecord::Migration[7.0]
  def change
    change_column :report_raw_data, :status_created_date, :datetime
    change_column :report_raw_data, :order_status_created_date, :datetime
  end
end
