# frozen_string_literal: true

# Reports flat table
class CreateReportRawData < ActiveRecord::Migration[7.0]
  def change
    create_table :report_raw_data do |t|
      t.integer :test_id
      t.date    :created_date
      t.string  :test_type
      t.string  :specimen
      t.integer :status_id
      t.string  :status_name
      t.integer :order_status_id
      t.string  :order_status_name
      t.integer :test_indicator_id
      t.string  :test_indicator_name
      t.string  :result
      t.date    :dob
      t.string  :ward
      t.string  :department
      t.string  :encounter_type
      t.datetime :updated_at
    end
    add_index :report_raw_data, [:test_id, :test_indicator_id, :status_id], unique: true, name: 'report_raw_data_index_unique_keys'
  end
end
