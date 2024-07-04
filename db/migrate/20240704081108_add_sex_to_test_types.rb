# frozen_string_literal: true
#
# Add Sex to test type migration
class AddSexToTestTypes < ActiveRecord::Migration[7.0]
  def change
    add_column :test_types, :sex, :string, default: 'Both'
  end
end
