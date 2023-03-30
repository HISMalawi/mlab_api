class CreateTestResults < ActiveRecord::Migration[7.0]
  def change
    create_table :test_results do |t|
      t.references :test, null: false, foreign_key: true
      t.references :test_indicator, null: false, foreign_key: true
      t.text :value
      t.datetime :result_date
      t.integer :voided
      t.bigint :voided_by
      t.string :voided_reason
      t.datetime :voided_date
      t.bigint :creator
      t.datetime :created_date
      t.datetime :updated_date

      
    end
  end
end
