class AddIndexToCreateDateInTests < ActiveRecord::Migration[7.0]
  def change
    add_index :tests, :created_date
  end
end
