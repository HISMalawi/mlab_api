class AddIndexToOrderOnCollecteBy < ActiveRecord::Migration[7.0]
  def change
    add_index :orders, :collected_by, if_not_exists: true
    add_index :orders, :requested_by, if_not_exists: true
  end
end
