class Drug < RetirableRecord
  validates :name, uniqueness: true, presence: true
  has_many :drug_susceptibilities
end
