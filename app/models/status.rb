class Status < RetirableRecord
  validates :name, uniqueness: true, presence: true
end
