class CreateClientOrderPrintTrails < ActiveRecord::Migration[7.0]
  def change
    create_table :client_order_print_trails do |t|
      t.references :order, null: false, foreign_key: true
      t.bigint :creator
      t.integer :voided
      t.bigint :voided_by
      t.string :voided_reason
      t.datetime :voided_date
      t.datetime :created_date
      t.datetime :updated_date

      t.timestamps
    end
  end
end
