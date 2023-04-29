class Global < RetirableRecord
  validates :name, uniqueness: true, presence: true
end
