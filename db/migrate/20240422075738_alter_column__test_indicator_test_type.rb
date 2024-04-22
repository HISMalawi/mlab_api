class AlterColumnTestIndicatorTestType < ActiveRecord::Migration[7.0]
  def change
    change_table :test_indicators do |t|
      t.change :test_type_id, :bigint, null: true
    end
  end
end
