class AddSoundexColumnsToPeople < ActiveRecord::Migration[7.0]
  def change
    add_column :people, :first_name_soundex, :string
    add_column :people, :last_name_soundex, :string
  end
end
