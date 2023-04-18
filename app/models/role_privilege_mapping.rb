class RolePrivilegeMapping < RetirableRecord
  belongs_to :role
  belongs_to :privilege
end
