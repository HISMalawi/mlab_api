class Specimen < RetirableRecord
  validates :name, uniqueness: true, presence: true
  has_many :specimen_test_type_mappings
  has_many :test_types, through: :specimen_test_type_mappings
end
