class AddPersonTalkedToColumnToOrderStatus < ActiveRecord::Migration[7.0]
  def change
    add_column :order_statuses, :person_talked_to, :string
  end
end
