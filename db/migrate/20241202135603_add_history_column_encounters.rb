# frozen_string_literal: true

# Adds a column to the encounters table
class AddHistoryColumnEncounters < ActiveRecord::Migration[7.0]
  def change
    add_column :encounters, :client_history, :string, null: true
  end
end
