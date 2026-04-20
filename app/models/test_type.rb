# frozen_string_literal: true

# Model for TestTypes table
class TestType < TestTypeVoidableRecord
  validates :name, uniqueness: { conditions: -> { where(retired: false, disabled: false) } }, presence: true
  validates :preferred_name, uniqueness: { conditions: -> { where(retired: false, disabled: false) } }, presence: true
  belongs_to :department
  has_many :instrument_test_type_mapping
  has_many :specimen_test_type_mappings
  has_many :specimens, through: :specimen_test_type_mappings
  has_many :tests, dependent: :restrict_with_error
  has_many :test_type_organism_mappings, class_name: 'TestTypeOrganismMapping'
  has_many :organisms, through: :test_type_organism_mappings
  has_many :test_type_test_indicators, class_name: 'TestTypeTestIndicator', foreign_key: 'test_types_id'
  has_many :test_indicators, through: :test_type_test_indicators, source: :test_indicator
  has_one :expected_tats, required: false, class_name: 'ExpectedTat'
  has_many :test_type_lab_test_sites, class_name: 'TestTypeLabTestSite'
  has_many :lab_test_sites, through: :test_type_lab_test_sites
  has_many :test_type_panel_mappings, dependent: :destroy
  has_many :test_types, through: :test_type_panel_mappings
  has_many :test_type_attributes, dependent: :destroy
  has_many :custom_attributes, through: :test_type_attributes, source: :attribute_definition

  # Scope for active test types
  scope :active, -> { where.not(retired: true).where.not(disabled: true) }

  def as_json(options = {})
    base_json = super(options).merge(expected_turn_around_time: expected_tats, department:)

    # Include attributes if requested
    if options[:include_attributes]
      base_json[:attributes] = TestTypeAttribute.attributes_for_test_type(id, include_children: true)
    end

    return base_json if options[:single_item].nil?

    base_json.merge({
                      department:,
                      specimens:,
                      organisms:,
                      indicators: test_indicators,
                      expected_turn_around_time: expected_tats,
                      attributes: if options[:include_attributes]
                                    TestTypeAttribute.attributes_for_test_type(id,
                                                                               include_children: true)
                                  else
                                    []
                                  end
                    })
  end

  def self.search(search_term)
    where("name LIKE '%#{search_term}%' OR short_name LIKE '%#{search_term}%' OR preferred_name LIKE '%#{search_term}%'
      OR nlims_code LIKE '%#{search_term}%' OR moh_code LIKE '%#{search_term}%' OR loinc_code LIKE '%#{search_term}%'
    ")
  end
end
