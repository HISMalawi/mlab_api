# frozen_string_literal: true
# 

# Migration to add index to client_identifier table
class AddIndexToClientIDentifier < ActiveRecord::Migration[7.0]
  def change
    add_index :client_identifiers, [:value, :client_identifier_type_id], if_not_exists: true
  end
end
