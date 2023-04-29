class CreateEncounterTypes < ActiveRecord::Migration[7.0]
  def change
    create_table :encounter_types do |t|
      t.string :name
      t.string :description
      
      t.bigint :creator
      t.integer :voided
      t.bigint :voided_by
      t.string :voided_reason
      t.datetime :voided_date
      t.datetime :created_date
      t.datetime :updated_date

      # add_foreign_key :encounter_types, :users, column: :creator, primary_key: :id
    end
  end
end
