# frozen_string_literal: true

# AddLabLocationToTests migration
class AddLabLocationToTests < ActiveRecord::Migration[7.0]
  def up
    locations = ['Main Lab', 'Cancer Lab', 'Paediatric Lab']
    locations.each do |name|
      LabLocation.find_or_create_by(name:)
    end
    add_column :tests, :lab_location_id, :bigint, foreign_key: true, default: 1
    add_index :tests, :lab_location_id
    add_foreign_key :tests, :lab_locations, column: :lab_location_id, primary_key: :id
  end

  def down
    if ActiveRecord::Base.connection.column_exists?(:tests, :lab_location_id)
      result = ActiveRecord::Base.connection.execute("SELECT CONSTRAINT_NAME FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE
        WHERE TABLE_NAME = 'tests' AND COLUMN_NAME = 'lab_location_id' AND CONSTRAINT_NAME LIKE 'fk_%';")
      foreign_key_name = result&.first&.first
      if foreign_key_name
        ActiveRecord::Base.connection.execute("ALTER TABLE tests DROP FOREIGN KEY #{foreign_key_name};")
      end
      ActiveRecord::Base.connection.execute('ALTER TABLE tests DROP COLUMN lab_location_id;')
    end
    LabLocation.delete_all
  end
end
