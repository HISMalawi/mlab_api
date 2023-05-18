class AddPersonTalkedToColumnToTestStatus < ActiveRecord::Migration[7.0]
  def change
    add_column :test_statuses, :person_talked_to, :string
  end
end
