class Role < RetirableRecord
  validates :name, uniqueness: true, presence: true
end
