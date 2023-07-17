class UnsyncOrders < ActiveRecord::Migration[7.0]
  def change
    create_table :unsync_orders do |t|
      t.bigint :test_or_order_id, null: false
      t.string :data_not_synced, null: false
      t.string :data_level, null: false
      t.boolean :sync_status, null: false
      t.bigint :creator, null: true
      t.integer :voided, default: false
      t.bigint :voided_by, null: true
      t.string :voided_reason, null: true
      t.datetime :voided_date, null: true
      t.datetime :created_date, null: false
      t.datetime :updated_date, null: false
      t.datetime :updated_by, null: true
    end

    add_foreign_key :unsync_orders, :users, column: :creator, primary_key: :id
    add_foreign_key :unsync_orders, :users, column: :voided_by, primary_key: :id
  end
end
