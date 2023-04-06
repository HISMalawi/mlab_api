# fronzen_string_literal: true

module UserManagement 
  module RoleService
    class << self

      def create_role(role_params)
        ActiveRecord::Base.transaction do
          role = Role.create!(name: role_params[:name])
          role_params[:privileges].each do |privilege|
            RolePrivilegeMapping.create!(role_id: role.id, privilege_id: privilege)
          end
          role
        end
      end

      def update_role(role, role_params)
        ActiveRecord::Base.transaction do
          role.update!(name: role_params[:name])
          RolePrivilegeMapping.where(role_id: role.id).where.not(privilege_id: role_params[:privileges]).each do |role_privilege|
            role_privilege.void('Removed')
          end
          role_params[:privileges].each do |privilege|
            RolePrivilegeMapping.find_or_create_by(role_id: role.id, privilege_id: privilege)
          end
          role
        end
      end

      def update_permission(role_privileges)
        role_privileges.each do |role_privilege|
          privileges = role_privilege[:privileges].each.with_object(:id).map(&:[])
          RolePrivilegeMapping.where(role_id: role_privilege[:id]).where.not(privilege_id: privileges).each do |role_privilege_mapping|
            role_privilege_mapping.void('Removed')
          end
          privileges.each do |privilege|
            RolePrivilegeMapping.find_or_create_by!(role_id: role_privilege[:id], privilege_id: privilege)
          end
        end
      end

      def delete_role(role, reason)
        role.void(reason)
        RolePrivilegeMapping.where(role_id: role).each do |role_privilege|
          role_privilege.void(reason)
        end
      end

      def serialize_role(role)
        role_privileges = RolePrivilegeMapping.joins(:privilege, :role).where(role_id: role.id).select('privileges.id, privileges.name, privileges.display_name')
        {
          id: role.id,
          name: role.name,
          privileges: role_privileges
        }
      end
    
      def serialize_roles(roles)
        r = []
        roles.each do |role|
          r << serialize_role(role)
        end
        r
      end

    end
  end
end