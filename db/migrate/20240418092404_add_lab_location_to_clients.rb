# frozen_string_literal: true

# AddLabLocationToClients migration
class AddLabLocationToClients < ActiveRecord::Migration[7.0]
  def up
    add_column :clients, :lab_location_id, :bigint, foreign_key: true, default: 1, null: false
    add_index :clients, :lab_location_id
    add_index :clients, %i[voided lab_location_id]
    add_foreign_key :clients, :lab_locations, column: :lab_location_id, primary_key: :id
    change_column :tests, :lab_location_id, :bigint, null: false
  end

  def down
    return unless ActiveRecord::Base.connection.column_exists?(:clients, :lab_location_id)

    ActiveRecord::Base.connection.execute('DROP INDEX index_clients_on_voided_and_lab_location_id ON clients;')
    result = ActiveRecord::Base.connection.execute("SELECT CONSTRAINT_NAME FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE
        WHERE TABLE_NAME = 'clients' AND COLUMN_NAME = 'lab_location_id' AND CONSTRAINT_NAME LIKE 'fk_%';")
    foreign_key_name = result&.first&.first
    if foreign_key_name
      ActiveRecord::Base.connection.execute("ALTER TABLE clients DROP FOREIGN KEY #{foreign_key_name};")
    end
    ActiveRecord::Base.connection.execute('ALTER TABLE clients DROP COLUMN lab_location_id;')
  end
end
