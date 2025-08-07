class CreateAppSettings < ActiveRecord::Migration[7.0]
  def change
    return if table_exists?(:app_settings)

    create_table :app_settings do |t|
      t.string :name
      t.string :value
      t.integer :voided
      t.bigint :voided_by
      t.string :voided_reason
      t.datetime :voided_date
      t.bigint :creator
      t.datetime :created_date, null: false
      t.datetime :updated_date, null: false
      t.bigint :updated_by, null: true
    end
    add_foreign_key :app_settings, :users, column: :creator, primary_key: :id
    add_foreign_key :app_settings, :users, column: :updated_by, primary_key: :id
    add_foreign_key :app_settings, :users, column: :voided_by, primary_key: :id
    add_index :app_settings, :name, unique: true
  end
end
