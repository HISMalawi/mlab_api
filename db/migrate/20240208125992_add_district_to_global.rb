# frozen_string_literal: true

# Migration to add district column to globs table
class AddDistrictToGlobal < ActiveRecord::Migration[7.0]
  def change
    add_column :globals, :district, :string
  end
end
