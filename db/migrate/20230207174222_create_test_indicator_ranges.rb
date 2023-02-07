class CreateTestIndicatorRanges < ActiveRecord::Migration[7.0]
  def change
    create_table :test_indicator_ranges do |t|
      t.references :test_indicator, null: false, foreign_key: true
      t.integer :min_age
      t.integer :max_age
      t.string :sex
      t.bigint :lower_range
      t.bigint :upper_range
      t.string :interpretation
      t.string :value
      t.integer :retired
      t.bigint :retired_by
      t.string :retired_reason
      t.datetime :retired_date
      t.bigint :creator
      t.datetime :created_date
      t.datetime :updated_date

      t.timestamps
    end
  end
end
