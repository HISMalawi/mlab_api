# frozen_string_literal: true

# migration to add tracking to users table
class AddTrackableToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :sign_in_count, :integer, default: 0
    add_column :users, :last_sign_in_at, :datetime
    add_column :users, :current_sign_in_at, :datetime
    add_column :users, :last_log_out_at, :datetime
    add_column :users, :last_jwt_refresh_at, :datetime
    add_column :users, :token_version, :string
    add_index :users, :token_version, unique: true
  end
end
