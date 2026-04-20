# frozen_string_literal: true

# Model for TestTypeAttribute table
# Mapping table that connects attributes to test types with specific configurations
class TestTypeAttribute < VoidableRecord
  # Associations
  belongs_to :test_type
  belongs_to :attribute_definition, class_name: 'Attribute', foreign_key: 'attribute_id'
  belongs_to :parent_attribute, class_name: 'Attribute', optional: true

  # Validations
  validates :test_type_id, presence: true
  validates :attribute_id, presence: true
  validates :test_type_id, uniqueness: {
    scope: :attribute_id,
    conditions: -> { where(voided: [0, nil]) },
    message: 'already has this attribute assigned'
  }
  validate :validate_parent_relationship
  validate :validate_test_type_specific_options

  # Scopes
  scope :active, -> { where(active: true, voided: [0, nil]) }
  scope :for_test_type, ->(test_type_id) { where(test_type_id: test_type_id) }
  scope :required, -> { where(is_required: true) }
  scope :optional, -> { where(is_required: false) }
  scope :root_attributes, -> { where(parent_attribute_id: nil) }
  scope :ordered, -> { order(:sort_order, :id) }

  # Serialize test_type_specific_options as JSON
  serialize :test_type_specific_options, JSON

  def as_json(options = {})
    # Only include essential fields for the UI
    base_json = {
      id: id,
      test_type_id: test_type_id,
      attribute_id: attribute_id,
      is_required: is_required,
      sort_order: sort_order,
      parent_attribute_id: parent_attribute_id,
      parent_attribute_value: parent_attribute_value,
      attribute: {
        id: attribute_definition.id,
        name: attribute_definition.name,
        label: attribute_definition.label,
        description: attribute_definition.description,
        field_type: attribute_definition.field_type,
        options: attribute_definition.options
      },
      effective_options: effective_options
    }

    if parent_attribute.present?
      base_json[:parent_attribute] = {
        id: parent_attribute.id,
        name: parent_attribute.name,
        label: parent_attribute.label
      }
    end

    # Include child attributes if requested
    base_json[:child_attributes] = child_attributes_for_test_type if options[:include_children]

    base_json
  end

  # Get all attributes for a test type including dependent attributes
  def self.attributes_for_test_type(test_type_id, include_children: false)
    attrs = active.for_test_type(test_type_id).ordered
                  .includes(:attribute_definition, :parent_attribute)

    return attrs unless include_children

    attrs.map { |tta| tta.as_json(include_children: true) }
  end

  # Get only root-level attributes (no parent) for a test type
  def self.root_attributes_for_test_type(test_type_id)
    active.for_test_type(test_type_id).root_attributes.ordered
          .includes(:attribute_definition)
  end

  # Get effective options (test type specific options override default attribute options)
  def effective_options
    test_type_specific_options.presence || attribute_definition.options
  end

  # Get child attributes for this test type
  def child_attributes_for_test_type
    TestTypeAttribute.active
                     .for_test_type(test_type_id)
                     .where(parent_attribute_id: attribute_id)
                     .ordered
                     .includes(:attribute_definition)
                     .as_json(include_children: true)
  end

  # Check if this attribute should be shown based on parent value
  def should_show_for_parent_value?(value)
    return true if parent_attribute_id.blank?

    parent_attribute_value.to_s == value.to_s
  end

  private

  def validate_parent_relationship
    return if parent_attribute_id.blank?

    # Ensure parent_attribute_value is provided
    if parent_attribute_value.blank?
      errors.add(:parent_attribute_value, 'must be provided when parent_attribute is set')
      return
    end

    # Prevent self-reference
    if parent_attribute_id == attribute_id
      errors.add(:parent_attribute_id, 'cannot be the same as the attribute itself')
      return
    end

    # Ensure parent attribute is also assigned to the same test type
    unless TestTypeAttribute.active.exists?(test_type_id: test_type_id, attribute_id: parent_attribute_id)
      errors.add(:parent_attribute_id, 'must also be assigned to this test type')
    end

    # Prevent circular dependencies
    return unless would_create_circular_dependency?

    errors.add(:parent_attribute_id, 'would create a circular dependency')
  end

  def validate_test_type_specific_options
    return if test_type_specific_options.blank?
    return unless attribute_definition.present?

    # Only validate if the attribute requires options
    return unless %w[select radio checkbox].include?(attribute_definition.field_type)

    return if test_type_specific_options.is_a?(Array)

    errors.add(:test_type_specific_options, 'must be an array')
  end

  def would_create_circular_dependency?
    return false if parent_attribute_id.blank?

    visited = Set.new([attribute_id])
    current_parent_id = parent_attribute_id

    while current_parent_id.present?
      return true if visited.include?(current_parent_id)

      visited << current_parent_id

      # Find the parent's parent in this test type
      parent_mapping = TestTypeAttribute.active
                                        .find_by(test_type_id: test_type_id,
                                                 attribute_id: current_parent_id)
      current_parent_id = parent_mapping&.parent_attribute_id
    end

    false
  end
end
