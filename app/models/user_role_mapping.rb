class UserRoleMapping < ApplicationRecord
  belongs_to :user
  belongs_to :role
end
