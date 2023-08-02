class Organism < RetirableRecord
  has_many :drug_organism_mappings
  has_many :drugs, through: :drug_organism_mappings
  validates :name, uniqueness: true, presence: true
end
