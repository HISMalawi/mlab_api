class TestPanel < RetirableRecord
  validates :name, uniqueness: true, presence: true
end
