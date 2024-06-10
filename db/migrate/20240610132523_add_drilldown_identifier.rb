# frozen_string_literal: true

# Migration for creating table to store ids to be used for drilldown
class AddDrilldownIdentifier < ActiveRecord::Migration[7.0]
  def change
    create_table :drilldown_identifiers, id: false do |t|
      t.string :id, null: false, unique: true, index: true, limit: 36, primary_key: true, id: false
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
    add_foreign_key :drilldown_identifiers, :users, column: :creator, primary_key: :id
    add_foreign_key :drilldown_identifiers, :users, column: :updated_by, primary_key: :id
    add_foreign_key :drilldown_identifiers, :users, column: :voided_by, primary_key: :id
  end
end
