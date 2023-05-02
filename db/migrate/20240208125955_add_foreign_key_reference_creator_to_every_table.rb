class AddForeignKeyReferenceCreatorToEveryTable < ActiveRecord::Migration[7.0]
  def change
    ActiveRecord::Base.connection.tables.each do |table|
      column_names = ActiveRecord::Base.connection.columns(table).map(&:name)
      add_fk(affected_table: table, col: :retired_by, ref_table: :users) if column_names.include?('retired_by') && !foreign_key_exists?(table, column: :retired_by)
      add_fk(affected_table: table, col: :voided_by, ref_table: :users) if column_names.include?('voided_by') && !foreign_key_exists?(table, column: :voided_by)
      add_fk(affected_table: table, col: :creator, ref_table: :users) if column_names.include?('creator') && !foreign_key_exists?(table, column: :creator)
      add_fk(affected_table: table, col: :updated_by, ref_table: :users) if column_names.include?('updated_by') && !foreign_key_exists?(table, column: :updated_by)
      add_fk(affected_table: table, col: :destination_id, ref_table: :facilities) if column_names.include?('destination_id') && !foreign_key_exists?(table, column: :destination_id)
    end
  end
  
  def add_fk(affected_table:, col:, ref_table:)
    add_foreign_key affected_table, ref_table, column: col, primary_key: :id
  end

  def foreign_key_exists?(table, column:)
    foreign_keys = ActiveRecord::Base.connection.foreign_keys(table)
    foreign_keys.any? { |fk| fk.column == column.to_s }
  end
end
