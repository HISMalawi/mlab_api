class UserRoleMapping < RetirableRecord
  belongs_to :user
  belongs_to :role
end
