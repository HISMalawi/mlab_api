class CreateOrderStatuses < ActiveRecord::Migration[7.0]
  def change
    create_table :order_statuses do |t|
      t.references :order, null: false, foreign_key: true
      t.references :status, null: false, foreign_key: true
      t.references :status_reason, null: true, foreign_key: true
      t.bigint :creator, null: false
      t.integer :voided, default: false
      t.bigint :voided_by, null: true
      t.string :voided_reason, null: true
      t.datetime :voided_date, null: true
      t.datetime :created_date, null: false
      t.datetime :updated_date, null: false
    end

    add_foreign_key :order_statuses, :users, column: :creator, primary_key: :id
    add_foreign_key :order_statuses, :users, column: :voided_by, primary_key: :id
  end
end
