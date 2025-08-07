# frozen_string_literal: true

# Model for Drugs table
class Drug < RetirableRecord
  validates :name, uniqueness: true, presence: true
  has_many :drug_organism_mapping, dependent: :restrict_with_error, class_name: 'DrugOrganismMapping'
  has_many :organisms, through: :drug_organism_mapping
  has_many :drug_susceptibilities
end
