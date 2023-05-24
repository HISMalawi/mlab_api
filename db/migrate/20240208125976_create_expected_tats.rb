class CreateExpectedTats < ActiveRecord::Migration[7.0]
  def change
    create_table :expected_tats do |t|
      t.references :test_type, null: false, foreign_key: true
      t.string :value
      t.string :unit
      t.integer :voided
      t.bigint :voided_by
      t.string :voided_reason
      t.datetime :voided_date
      t.bigint :creator
      t.datetime :created_date
      t.datetime :updated_date
      t.bigint :updated_by
    end
  end
end
