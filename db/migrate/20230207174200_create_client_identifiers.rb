class CreateClientIdentifiers < ActiveRecord::Migration[7.0]
  def change
    create_table :client_identifiers do |t|
      t.references :client_identifier_type, null: false, foreign_key: true
      t.string :value
      t.references :client, null: false, foreign_key: true
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
