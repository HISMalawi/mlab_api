# frozen_string_literal: true

class ExpandEncounterClientHistory < ActiveRecord::Migration[7.0]
  def change
    change_column :encounters, :client_history, :text, null: true
  end
end
