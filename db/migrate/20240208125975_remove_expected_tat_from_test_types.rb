class RemoveExpectedTatFromTestTypes < ActiveRecord::Migration[7.0]
  def change
    remove_column :test_types, :expected_turn_around_time
  end
end
