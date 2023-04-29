class CreateGlobals < ActiveRecord::Migration[7.0]
  def change
    create_table :globals do |t|
      t.string :name
      t.string :code
      t.string :address
      t.string :phone
      t.bigint :creator
      t.integer :retired
      t.bigint :retired_by
      t.string :retired_reason
      t.datetime :retired_date
      t.datetime :created_date
      t.datetime :updated_date
    end
  end
end
