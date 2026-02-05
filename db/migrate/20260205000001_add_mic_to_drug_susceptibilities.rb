# frozen_string_literal: true

# Adds a 'mic' column to the drug_susceptibilities table
class AddMicToDrugSusceptibilities < ActiveRecord::Migration[7.0]
  def up
    return if column_exists?(:drug_susceptibilities, :mic)

    add_column :drug_susceptibilities, :mic, :string, limit: 15
  end

  def down
    return unless column_exists?(:drug_susceptibilities, :mic)

    remove_column :drug_susceptibilities, :mic
  end
end
