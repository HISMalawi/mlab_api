# frozen_string_literal: true

# RolePrivilegeMapping model
class RolePrivilegeMapping < VoidableRecord
  belongs_to :role
  belongs_to :privilege
end
