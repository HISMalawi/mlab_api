class CreateTestStatuses < ActiveRecord::Migration[7.0]
  def change
    create_table :test_statuses do |t|
      t.references :test, null: false, foreign_key: true
      t.references :status, null: false, foreign_key: true
      t.references :status_reason, null: false, foreign_key: true
      t.bigint :creator
      t.integer :voided
      t.bigint :voided_by
      t.string :voided_reason
      t.datetime :voided_date
      t.datetime :created_date
      t.datetime :updated_date

      t.timestamps
    end
  end
end
