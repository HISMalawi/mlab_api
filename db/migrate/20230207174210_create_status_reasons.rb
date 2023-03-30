class CreateStatusReasons < ActiveRecord::Migration[7.0]
  def change
    create_table :status_reasons do |t|
      t.text :description
      t.integer :retired
      t.bigint :retired_by
      t.string :retired_reason
      t.datetime :retired_date
      t.bigint :creator
      t.datetime :updated_date
      t.datetime :created_date

      
    end
  end
end
