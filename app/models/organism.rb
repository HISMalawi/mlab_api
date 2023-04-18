class Organism < RetirableRecord
  validates :name, uniqueness: true, presence: true
end
