class Specimen < RetirableRecord
  validates :name, uniqueness: true, presence: true
end
