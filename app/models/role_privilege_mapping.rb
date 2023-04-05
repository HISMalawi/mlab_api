class RolePrivilegeMapping < VoidableRecord
  belongs_to :role
  belongs_to :privilege
end
