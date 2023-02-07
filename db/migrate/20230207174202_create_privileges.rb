class CreatePrivileges < ActiveRecord::Migration[7.0]
  def change
    create_table :privileges do |t|
      t.bigint :name
      t.integer :retired
      t.bigint :retired_by
      t.string :retired_reason
      t.datetime :retired_date
      t.bigint :creator
      t.datetime :updated_date
      t.datetime :created_date

      t.timestamps
    end
  end
end
