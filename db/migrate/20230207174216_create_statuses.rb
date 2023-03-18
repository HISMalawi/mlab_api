class CreateStatuses < ActiveRecord::Migration[7.0]
  def change
    create_table :statuses do |t|
      t.string :name
      t.integer :retired
      t.bigint :retired_by
      t.string :retired_reason
      t.datetime :retired_date
      t.bigint :creator
      t.datetime :created_date
      t.datetime :updated_date

      t.timestamps
    end
  end
end
