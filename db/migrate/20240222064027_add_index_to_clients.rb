class AddIndexToClients < ActiveRecord::Migration[7.0]
  def change
    add_index :clients, :created_date
  end
end
