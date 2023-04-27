class Instrument < RetirableRecord
  validates :name, presence: true, uniqueness: true
end
