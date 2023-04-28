class Department < RetirableRecord
  validates :name, uniqueness: true, presence: true
  has_many :user_department_mappings
end
