class UserDepartmentMapping < RetirableRecord
  belongs_to :user
  belongs_to :department
end
