class AddIndexToPeople < ActiveRecord::Migration[7.0]
  def change
    add_index :people, :voided
    add_index :people, :first_name
    add_index :people, :last_name
    add_index :people, :sex
    add_index :people, :date_of_birth
    add_index :people, :first_name_soundex
    add_index :people, :last_name_soundex
  end
end
