class CreateMohReportDataMaterialized < ActiveRecord::Migration[7.0]
  def change
    create_table :moh_report_data_materialized do |t|
      t.datetime :created_date
      t.string :indicator
      t.integer :total
      t.string :department
    end
  end
end
