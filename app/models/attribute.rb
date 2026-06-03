# frozen_string_literal: true

# Model for Attribute table
# Generic attributes that can be reused across different entities (tests, orders, encounters, etc.)
class Attribute < VoidableRecord
  # Associations
  has_many :test_type_attributes, dependent: :destroy, foreign_key: 'attribute_id'
  has_many :test_types, through: :test_type_attributes
  has_many :test_attribute_values, dependent: :destroy, foreign_key: 'attribute_id'

  # Validations
  validates :name, presence: true, uniqueness: { conditions: -> { where(voided: [0, nil]) } }
  validates :label, presence: true
  validates :field_type, presence: true, inclusion: {
    in: %w[text number select radio checkbox date yes_no textarea],
    message: '%<value>s is not a valid field type'
  }
  validate :validate_options_for_type

  # Scopes
  scope :active, -> { where(active: true, voided: [0, nil]) }
  scope :by_field_type, ->(type) { where(field_type: type) }

  # Serialize options as JSON
  serialize :options, JSON

  def as_json(options = {})
    super(options).merge(
      test_types: test_types.active.as_json(only: %i[id name short_name])
    )
  end

  private

  def validate_options_for_type
    return unless %w[select radio checkbox].include?(field_type)

    if options.blank?
      errors.add(:options, "must be provided for #{field_type} field type")
    elsif !options.is_a?(Array)
      errors.add(:options, 'must be an array of options')
    elsif options.empty?
      errors.add(:options, "cannot be empty for #{field_type} field type")
    end
  end
end
