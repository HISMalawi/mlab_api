# frozen_string_literal: true

#  remarks table
class CreateRemarks < ActiveRecord::Migration[7.0]
  def change
    create_table :remarks do |t|
      t.references :tests, null: false, foreign_key: true
      t.text :value
      t.integer :voided
      t.bigint :voided_by
      t.string :voided_reason
      t.datetime :voided_date
      t.bigint :creator
      t.datetime :created_date, null: false
      t.datetime :updated_date, null: false
      t.bigint :updated_by, null: true
    end
    add_foreign_key :remarks, :users, column: :creator, primary_key: :id
    add_foreign_key :remarks, :users, column: :updated_by, primary_key: :id
    add_foreign_key :remarks, :users, column: :voided_by, primary_key: :id
  end
end
