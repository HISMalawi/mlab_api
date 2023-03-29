class AddUpdatedByColumnToEveryTable < ActiveRecord::Migration[7.0]
  def change
    ActiveRecord::Base.connection.tables.each do |table|
      add_column_to_table(affected_table: table, col: 'updated_by')
    end
  end
  
  def add_column_to_table(affected_table:, col:)
    add_column affected_table, col, :bigint
  end
end
