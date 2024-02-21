class AddIndexToTests < ActiveRecord::Migration[7.0]
  def change
    add_index :tests, :voided
  end
end
