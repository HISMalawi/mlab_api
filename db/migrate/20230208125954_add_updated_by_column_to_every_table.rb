class AddUpdatedByColumnToEveryTable < ActiveRecord::Migration[7.0]
  def change
    ActiveRecord::Base.connection.tables.each do |table|
      column_names = ActiveRecord::Base.connection.columns(table).map(&:name)
      add_column_to_table(affected_table: table, col: 'updated_by') if column_names.include?('updated_date')
    end
  end
  
  def add_column_to_table(affected_table:, col:)
    add_column affected_table, col, :bigint
  end
end
