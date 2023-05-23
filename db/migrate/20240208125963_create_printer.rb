class CreatePrinter < ActiveRecord::Migration[7.0]
  def change
    create_table :printers do |t|
      t.string :name
      t.text :description
      t.integer :voided
      t.bigint :voided_by
      t.string :voided_reason
      t.datetime :voided_date
      t.bigint :creator
      t.datetime :created_date
      t.datetime :updated_date
      t.bigint :updated_by
    end
  end
end
