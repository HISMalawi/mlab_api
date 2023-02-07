class CreateCultureObservations < ActiveRecord::Migration[7.0]
  def change
    create_table :culture_observations do |t|
      t.references :test, null: false, foreign_key: true
      t.text :description
      t.datetime :observation_datetime
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
