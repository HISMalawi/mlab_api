class Drug < RetirableRecord
  validates :name, uniqueness: true, presence: true
end
