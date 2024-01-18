# frozen_string_literal: true

# Reports migration
class Reports < ActiveRecord::Migration[7.0]
  def change
    create_table :reports do |t|
      t.string :name
      t.json :data
      t.string :year
      t.datetime :report_date
      t.integer :voided
      t.bigint :voided_by
      t.string :voided_reason
      t.datetime :voided_date
      t.bigint :creator
      t.datetime :created_date, null: false
      t.datetime :updated_date, null: false
      t.bigint :updated_by, null: true
    end
    add_foreign_key :reports, :users, column: :creator, primary_key: :id
    add_foreign_key :reports, :users, column: :updated_by, primary_key: :id
    add_foreign_key :reports, :users, column: :voided_by, primary_key: :id
  end
end
