# frozen_string_literal: true

# Reports flat table
class CreateReportRawData < ActiveRecord::Migration[7.0]
  def change
    create_table :report_raw_data do |t|
      t.integer :test_id
      t.integer :encounter_id
      t.string  :encounter_type
      t.integer :patient_no
      t.string  :patient_name
      t.string :gender
      t.date    :dob
      t.string  :accession_number
      t.date    :created_date
      t.string  :test_type
      t.string  :specimen
      t.integer :status_id
      t.string  :status_name
      t.date    :status_created_date
      t.string  :status_creator
      t.string  :status_rejection_reason
      t.string  :status_person_talked_to
      t.integer :order_status_id
      t.string  :order_status_name
      t.date    :order_status_created_date
      t.string  :order_status_creator
      t.string  :order_rejection_reason
      t.string  :order_person_talked_to
      t.integer :test_indicator_id
      t.string  :test_indicator_name
      t.string  :result
      t.date    :result_date
      t.string  :ward
      t.string  :department
      t.datetime :updated_at
    end
    add_index :report_raw_data, [:test_id, :test_indicator_id, :status_id], unique: true, name: 'report_raw_data_index_unique_keys'
  end
end
