class CreateDisease < ActiveRecord::Migration[7.0]
  def change
    create_table :diseases do |t|
      t.string :name, unique: true, null: false
      t.integer :voided, default: false
      t.bigint :voided_by, null: true
      t.string :voided_reason, null: true
      t.datetime :voided_date, null: true
      t.bigint :creator, null: false
      t.datetime :created_date, null: false
      t.datetime :updated_date, null: false
    end

    add_foreign_key :diseases, :users, column: :creator, primary_key: :id
    add_foreign_key :diseases, :users, column: :voided_by, primary_key: :id
  end
end
