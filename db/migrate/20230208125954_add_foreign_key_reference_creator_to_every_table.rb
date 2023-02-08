class AddForeignKeyReferenceCreatorToEveryTable < ActiveRecord::Migration[7.0]
  def change
    tables = ActiveRecord::Base.connection.tables
    tables.each do |table|
      columns = ActiveRecord::Base.connection.columns(table)
      column_names = columns.map(&:name)
      if table == 'roles' || table == 'people'
        change_table table do |t|
          if column_names.include?('retired_by')
            t.remove :retired_by
            t.references :retired_by, null: true, foreign_key: {to_table: :users}
          end
          if column_names.include?('voided_by')
            t.remove :voided_by
            t.references :voided_by, null: true, foreign_key: {to_table: :users}
          end
          if column_names.include?('creator')
            t.remove :creator
            t.references :creator, null: true, foreign_key: {to_table: :users}
          end
        end
      else
        change_table table do |t|
          if column_names.include?('retired_by')
            t.remove :retired_by
            t.references :retired_by, null: true, foreign_key: {to_table: :users}
          end
          if column_names.include?('voided_by')
            t.remove :voided_by
            t.references :voided_by, null: true, foreign_key: {to_table: :users}
          end
          if column_names.include?('creator')
            t.remove :creator
            t.references :creator, null: false, foreign_key: {to_table: :users}
          end
          if column_names.include?('destination_id')
            t.remove :destination_id
            t.references :destination, null: false, foreign_key: {to_table: :facilities}
          end
        end
      end
    end
  end
end
