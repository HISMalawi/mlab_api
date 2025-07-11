# frozen_string_literal: true

# Map privilege to role
class MapPrivileToRole < ActiveRecord::Migration[7.0]
  def change
    superadmins = Role.where(name: %w[Superadmin Superuser])
    privileges = Privilege.where(name: %w[view_stock_management manage_stock_management])
    superadmins.each do |superadmin|
      privileges.each do |privilege|
        RolePrivilegeMapping.find_or_create_by!(role_id: superadmin.id, privilege_id: privilege.id)
      end
    end
  end
end
