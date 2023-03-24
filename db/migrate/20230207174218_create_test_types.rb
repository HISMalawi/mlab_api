class CreateTestTypes < ActiveRecord::Migration[7.0]
  def change
    create_table :test_types do |t|
      t.string :name
      t.string :short_name
      t.references :department, null: false, foreign_key: true
      t.decimal :expected_turn_around_time, precision: 65, scale: 2 
      t.integer :retired
      t.bigint :retired_by
      t.string :retired_reason
      t.datetime :retired_date
      t.bigint :creator
      t.datetime :updated_date
      t.datetime :created_date

      t.timestamps
    end
  end
end
