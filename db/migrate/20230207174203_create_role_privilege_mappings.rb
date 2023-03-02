class CreateRolePrivilegeMappings < ActiveRecord::Migration[7.0]
  def change
    create_table :role_privilege_mappings do |t|
      t.references :role, null: false, foreign_key: true
      t.references :privilege, null: false, foreign_key: true
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
