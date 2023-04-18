class TestType < RetirableRecord
  belongs_to :department
  validates :name, uniqueness: true, presence: true
end
