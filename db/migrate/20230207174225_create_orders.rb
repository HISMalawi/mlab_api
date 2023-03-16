class CreateOrders < ActiveRecord::Migration[7.0]
  def change
    create_table :orders do |t|
      t.references :encounter, null: false, foreign_key: true
      t.references :priority, null: false, foreign_key: true
      t.string :accession_number
      t.string :tracking_number
      t.string :requested_by
      t.datetime :sample_collected_time
      t.string :collected_by
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
