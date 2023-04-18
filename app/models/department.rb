class Department < RetirableRecord
  validates :name, uniqueness: true, presence: true
end
