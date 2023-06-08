class CreateMohReportData < ActiveRecord::Migration[7.0]
  def change
    create_table :moh_report_data, id: false do |t|
      t.date    :created_date
      t.string  :indicator
      t.integer :total
      t.string  :department
      t.datetime :updated_at
    end
    add_index :moh_report_data, [:created_date, :indicator, :department], unique: true, name: 'moh_report_data_index_unique_keys'
  end
end