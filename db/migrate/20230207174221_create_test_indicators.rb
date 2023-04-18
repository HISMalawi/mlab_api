class CreateTestIndicators < ActiveRecord::Migration[7.0]
  def change
    create_table :test_indicators do |t|
      t.string :name
      t.references :test_type, null: false, foreign_key: true
      t.integer :test_indicator_type
      t.string :unit
      t.string :description
      t.integer :retired
      t.bigint :retired_by
      t.string :retired_reason
      t.datetime :retired_date
      t.bigint :creator
      t.datetime :created_date
      t.datetime :updated_date

      
    end
  end
end
