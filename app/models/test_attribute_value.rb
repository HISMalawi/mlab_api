# frozen_string_literal: true

# Model for TestAttributeValue table
# Stores actual attribute values for specific tests
class TestAttributeValue < VoidableRecord
  # Associations
  belongs_to :test
  belongs_to :attribute_definition, class_name: 'Attribute', foreign_key: 'attribute_id'

  # Validations
  validates :test_id, presence: true
  validates :attribute_id, presence: true
  validates :value, presence: true
  validates :test_id, uniqueness: {
    scope: :attribute_id,
    conditions: -> { where(voided: [0, nil]) },
    message: 'already has a value for this attribute'
  }
  validate :validate_value_format

  # Scopes
  scope :for_test, ->(test_id) { where(test_id: test_id, voided: [0, nil]) }
  scope :for_attribute, ->(attribute_id) { where(attribute_id: attribute_id, voided: [0, nil]) }

  def as_json(options = {})
    base_json = super(options)

    if options[:include_attribute]
      base_json[:attribute] =
        attribute_definition.as_json(only: %i[id name label field_type])
    end

    base_json[:test] = test.as_json(only: %i[id test_type_id]) if options[:include_test]

    base_json
  end

  # Get all attribute values for a test with attribute details
  def self.values_for_test(test_id)
    for_test(test_id)
      .includes(:attribute_definition)
      .map do |av|
        {
          id: av.id,
          attribute_id: av.attribute_id,
          attribute_name: av.attribute_definition.name,
          attribute_label: av.attribute_definition.label,
          field_type: av.attribute_definition.field_type,
          value: av.value,
          options: av.attribute_definition.options,
          created_date: av.created_date
        }
      end
  end

  # Get a specific attribute value for a test
  def self.value_for_test_and_attribute(test_id, attribute_id)
    for_test(test_id).for_attribute(attribute_id).first&.value
  end

  # Bulk create or update attribute values for a test
  def self.save_test_attributes(test_id, attributes_hash)
    return [] if attributes_hash.blank?

    results = []
    errors = []

    attributes_hash.each do |attribute_id, value|
      attr_value = find_or_initialize_by(
        test_id: test_id,
        attribute_id: attribute_id,
        voided: 0
      )

      attr_value.value = value
      attr_value.creator ||= User.current&.id
      attr_value.updated_by = User.current&.id
      attr_value.created_date ||= Time.current
      attr_value.updated_date = Time.current

      if attr_value.save
        results << attr_value
      else
        errors << { attribute_id: attribute_id, errors: attr_value.errors.full_messages }
      end
    rescue StandardError => e
      errors << { attribute_id: attribute_id, errors: [e.message] }
    end

    { saved: results, errors: errors }
  end

  private

  def validate_value_format
    return if value.blank? || attribute_definition.blank?

    case attribute_definition.field_type
    when 'number'
      errors.add(:value, 'must be a valid number') unless value.to_s.match?(/\A-?\d+\.?\d*\z/)
    when 'date'
      begin
        Date.parse(value.to_s)
      rescue ArgumentError
        errors.add(:value, 'must be a valid date')
      end
    when 'yes_no'
      errors.add(:value, "must be 'yes' or 'no'") unless %w[yes no Yes No YES NO true false 1 0].include?(value.to_s)
    when 'select', 'radio'
      # Validate against available options
      if attribute_definition.options.present? && !attribute_definition.options.include?(value.to_s)
        # Check if test type has specific options
        test_type_attr = TestTypeAttribute.active
                                          .find_by(test_type_id: test.test_type_id,
                                                   attribute_id: attribute_id)
        effective_opts = test_type_attr&.effective_options || attribute_definition.options

        errors.add(:value, 'is not a valid option for this attribute') unless effective_opts.include?(value.to_s)
      end
    end
  end
end
