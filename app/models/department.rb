# frozen_string_literal: true

# Model for Departments table
class Department < RetirableRecord
  validates :name, uniqueness: true, presence: true
  has_many :user_department_mappings
  has_many :test_types, class_name: 'TestType', dependent: :restrict_with_error
end
