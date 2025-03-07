class CreateAccessionNumberTracker < ActiveRecord::Migration[7.0]
  def change
    create_table :accession_number_trackers do |t|
      t.string :accession_number
      t.integer :voided
      t.bigint :voided_by
      t.string :voided_reason
      t.datetime :voided_date
      t.bigint :creator
      t.datetime :created_date, null: false
      t.datetime :updated_date, null: false
      t.bigint :updated_by, null: true
    end
    add_foreign_key :accession_number_trackers, :users, column: :creator, primary_key: :id
    add_foreign_key :accession_number_trackers, :users, column: :updated_by, primary_key: :id
    add_foreign_key :accession_number_trackers, :users, column: :voided_by, primary_key: :id
    add_index :accession_number_trackers, :accession_number, unique: true
    AccessionNumberTracker.create!(accession_number: Order.last&.accession_number)
  end
end
