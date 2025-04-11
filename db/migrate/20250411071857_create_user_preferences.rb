# frozen_string_literal: true

# This migration is for creating the user_preferences table
class CreateUserPreferences < ActiveRecord::Migration[7.0]
  def change
    create_table :user_preferences do |t|
      t.string :name
      t.string :value
      t.integer :voided
      t.bigint :voided_by
      t.string :voided_reason
      t.datetime :voided_date
      t.bigint :creator
      t.datetime :created_date, null: false
      t.datetime :updated_date, null: false
      t.bigint :updated_by, null: true
    end
    add_foreign_key :user_preferences, :users, column: :creator, primary_key: :id
    add_foreign_key :user_preferences, :users, column: :updated_by, primary_key: :id
    add_foreign_key :user_preferences, :users, column: :voided_by, primary_key: :id
    add_index :user_preferences, :name
    add_index :user_preferences, %i[name creator], unique: true
    add_index :user_preferences, %i[name voided], unique: true
    add_index :user_preferences, %i[name creator voided], unique: true
  end
end
