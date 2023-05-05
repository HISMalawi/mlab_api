class DrugSusceptibility < ActiveRecord::Migration[7.0]
  def change
    create_table :drug_susceptibilities do |t| 
      t.references :test, index: true, foreign_key: true
      t.references :organism, index: true, foreign_key: true
      t.references :drug, index: true, foreign_key: true
      t.string :zone
      t.string :interpretation
      t.integer :voided
      t.bigint :voided_by
      t.string :voided_reason
      t.datetime :voided_date
      t.bigint :creator
      t.datetime :created_date
      t.datetime :updated_date
      t.bigint :updated_by
    end

    add_foreign_key :drug_susceptibilities, :users, column: :creator, primary_key: :id
    add_foreign_key :drug_susceptibilities, :users, column: :voided_by, primary_key: :id
    add_foreign_key :drug_susceptibilities, :users, column: :updated_by, primary_key: :id
  end
end

