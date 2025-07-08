# frozen_string_literal: true

# Add Privilege Metadata Migration
class AddPrivilegeMetadata < ActiveRecord::Migration[7.0]
  def change
    Privilege.find_or_create_by!(
      name: 'view_stock_management',
      display_name: 'Can View Stock Management'
    )
    Privilege.find_or_create_by!(
      name: 'manage_stock_management',
      display_name: 'Can Manage Stock Management'
    )
  end
end
