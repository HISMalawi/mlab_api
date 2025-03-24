# frozen_string_literal: true

# Model for Organisms table
class Organism < RetirableRecord
  validates :name, uniqueness: true, presence: true
  has_many :drug_organism_mappings, class_name: 'DrugOrganismMapping'
  has_many :drugs, through: :drug_organism_mappings
  has_many :test_type_organism_mappings, class_name: 'TestTypeOrganismMapping'
end
