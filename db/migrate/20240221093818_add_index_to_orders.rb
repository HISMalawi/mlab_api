class AddIndexToOrders < ActiveRecord::Migration[7.0]
  def change
    add_index :orders, :created_date
    add_index :orders, :tracking_number
    add_index :orders, :accession_number
    add_index :orders, :voided
  end
end
