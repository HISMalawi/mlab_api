# frozen_string_literal: true

# lab_locations table
class CreateLabLocation < ActiveRecord::Migration[7.0]
  def change
    create_table :lab_locations do |t|
      t.string :name
      t.string :description
      t.integer :voided
      t.bigint :voided_by
      t.string :voided_reason
      t.datetime :voided_date
      t.bigint :creator
      t.datetime :created_date, null: false
      t.datetime :updated_date, null: false
      t.bigint :updated_by, null: true
    end
    add_foreign_key :lab_locations, :users, column: :creator, primary_key: :id
    add_foreign_key :lab_locations, :users, column: :updated_by, primary_key: :id
    add_foreign_key :lab_locations, :users, column: :voided_by, primary_key: :id
  end
end