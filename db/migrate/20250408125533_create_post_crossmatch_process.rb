# frozen_string_literal: true

# Migration for cross match process
class CreatePostCrossmatchProcess < ActiveRecord::Migration[7.0]
  def change
    return if table_exists?(:post_crossmatch_processes)

    create_table :post_crossmatch_processes do |t|
      t.bigint :facility_section_id
      t.bigint :test_id
      t.string :collected_by
      t.datetime :collection_date
      t.string :transfusion_outcome
      t.boolean :returned, default: false
      t.string :returned_by
      t.datetime :returned_date
      t.string :returned_reason
      t.integer :voided
      t.bigint :voided_by
      t.string :voided_reason
      t.datetime :voided_date
      t.bigint :creator
      t.datetime :created_date, null: false
      t.datetime :updated_date, null: false
      t.bigint :updated_by, null: true
    end
    add_index :post_crossmatch_processes, :id, unique: true
    add_foreign_key :post_crossmatch_processes, :users, column: :creator, primary_key: :id
    add_foreign_key :post_crossmatch_processes, :users, column: :updated_by, primary_key: :id
    add_foreign_key :post_crossmatch_processes, :users, column: :voided_by, primary_key: :id
    add_foreign_key :post_crossmatch_processes, :facility_sections, column: :facility_section_id, primary_key: :id
    add_foreign_key :post_crossmatch_processes, :tests, column: :test_id, primary_key: :id
  end
end
