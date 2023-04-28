class CreateDisease < ActiveRecord::Migration[7.0]
  def change
    create_table :diseases do |t|
      t.string :name
      t.timestamps
    end
  end
end
