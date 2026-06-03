# frozen_string_literal: true

# Model for Specimens table
class Specimen < RetirableRecord
  validates :name, uniqueness: true, presence: true
  has_many :tests, dependent: :restrict_with_error
  has_many :specimen_test_type_mappings
  has_many :test_types, through: :specimen_test_type_mappings

  scope :excluding_not_specified, lambda {
    where.not(id: find_by(name: 'not_Specified')&.id)
  }
end
