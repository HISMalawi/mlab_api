# frozen_string_literal: true

# Migration for pack number log
class CreatePackNumberLog < ActiveRecord::Migration[7.0]
  def change
    create_table :pack_number_logs do |t|
          t.bigint :test_id
          t.string :pack_number
          t.string :suffix
          t.integer :voided
          t.bigint :voided_by
          t.string :voided_reason
          t.datetime :voided_date
          t.bigint :creator
          t.datetime :created_date, null: false
          t.datetime :updated_date, null: false
          t.bigint :updated_by, null: true
    end
        add_index :pack_number_logs, :id, unique: true
        add_index :pack_number_logs, :pack_number
        add_foreign_key :pack_number_logs, :users, column: :creator, primary_key: :id
        add_foreign_key :pack_number_logs, :users, column: :updated_by, primary_key: :id
        add_foreign_key :pack_number_logs, :users, column: :voided_by, primary_key: :id
        add_foreign_key :pack_number_logs, :tests, column: :test_id, primary_key: :id
  end
end
