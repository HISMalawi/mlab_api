class CreateFacilitySections < ActiveRecord::Migration[7.0]
  def change
    create_table :facility_sections do |t|
      t.string :name
      t.integer :retired
      t.bigint :retired_by
      t.string :retired_reason
      t.datetime :retired_date
      t.bigint :creator
      t.datetime :created_date
      t.datetime :updated_date

      
    end
  end
end
