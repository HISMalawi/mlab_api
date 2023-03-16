class CreateUsers < ActiveRecord::Migration[7.0]
  def change
    create_table :users do |t|
      t.references :person, null: false, foreign_key: true
      t.string :username
      t.string :password
      t.string :last_password_changed
      t.integer :voided
      t.bigint :voided_by
      t.string :voided_reason
      t.datetime :voided_date
      t.bigint :creator
      t.datetime :created_date
      t.datetime :updated_date

      t.timestamps
    end
  end
end
