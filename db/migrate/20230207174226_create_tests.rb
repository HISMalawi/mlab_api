class CreateTests < ActiveRecord::Migration[7.0]
  def change
    create_table :tests do |t|
      t.references :specimen, null: false, foreign_key: true
      t.references :order, null: false, foreign_key: true
      t.references :test_type, null: false, foreign_key: true
      t.integer :voided
      t.bigint :voided_by
      t.string :voided_reason
      t.datetime :voided_date
      t.bigint :creator
      t.datetime :created_date
      t.datetime :updated_date

      
    end
  end
end
