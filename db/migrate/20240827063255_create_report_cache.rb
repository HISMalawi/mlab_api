# frozen_string_literal: true

# ReportCache migration
class CreateReportCache < ActiveRecord::Migration[7.0]
  def change
    create_table :report_caches, id: false do |t|
      t.string :id, limit: 36, primary_key: true, null: false
      t.json :data
      t.integer :voided
      t.bigint :voided_by
      t.string :voided_reason
      t.datetime :voided_date
      t.bigint :creator
      t.datetime :created_date, null: false
      t.datetime :updated_date, null: false
      t.bigint :updated_by, null: true
    end
    add_index :report_caches, :id, unique: true
    add_foreign_key :report_caches, :users, column: :creator, primary_key: :id
    add_foreign_key :report_caches, :users, column: :updated_by, primary_key: :id
    add_foreign_key :report_caches, :users, column: :voided_by, primary_key: :id
  end
end
