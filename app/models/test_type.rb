# frozen_string_literal: true

# Model for TestTypes table
class TestType < TestTypeVoidableRecord
  validates :name, uniqueness: true, presence: true
  belongs_to :department
  has_many :instrument_test_type_mapping
  has_many :specimen_test_type_mappings
  has_many :specimens, through: :specimen_test_type_mappings
  belongs_to :department
  has_many :tests, dependent: :restrict_with_error
  has_many :test_type_organism_mappings, class_name: 'TestTypeOrganismMapping'
  has_many :organisms, through: :test_type_organism_mappings
  has_many :test_type_test_indicator, class_name: 'TestTypeTestIndicator', foreign_key: 'test_types_id'
  has_many :test_indicators, through: :test_type_test_indicator
  has_one :expected_tats, required: false
  has_many :test_type_lab_test_sites, class_name: 'TestTypeLabTestSite'
  has_many :lab_test_sites, through: :test_type_lab_test_sites

  def as_json(options = {})
    methods = %i[expected_turn_around_time]
    super(options.merge(methods:))
  end

  def expected_turn_around_time
    ExpectedTat.where(test_type_id: id).first
  end

  def self.search(search_term)
    where("name LIKE '%#{search_term}%' OR short_name LIKE '%#{search_term}%'")
  end
end
