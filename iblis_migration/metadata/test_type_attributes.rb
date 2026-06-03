# frozen_string_literal: true

# This file is used to test the attributes metadata for test types.
# It ensures that the attributes are correctly loaded and associated with the test types.

tb_test_type_attributes = [
  {
    test_type_identifier: {
      nlims_code: "NLIMS_TT_0010_MWI",
      name: "TB Tests",
      short_name: "TB"
    },
    attribute_name: "Reason For Examination",
    is_required: false,
    sort_order: 1,
    parent_attribute_name: nil,
    parent_attribute_value: nil,
    test_type_specific_options: nil,
    active: true
  },
  {
    test_type_identifier: {
      nlims_code: "NLIMS_TT_0010_MWI",
      name: "TB Tests",
      short_name: "TB"
    },
    attribute_name: "Follow Up Period",
    is_required: false,
    sort_order: 2,
    parent_attribute_name: "Reason For Examination",
    parent_attribute_value: "Follow up",
    test_type_specific_options: nil,
    active: true
  },
  {
    test_type_identifier: {
      nlims_code: "NLIMS_TT_0010_MWI",
      name: "TB Tests",
      short_name: "TB"
    },
    attribute_name: "TB Treatment History",
    is_required: false,
    sort_order: 6,
    parent_attribute_name: nil,
    parent_attribute_value: nil,
    test_type_specific_options: nil,
    active: true
  },
  # {
  #   test_type_identifier: {
  #     nlims_code: "NLIMS_TT_0010_MWI",
  #     name: "TB Tests",
  #     short_name: "TB"
  #   },
  #   attribute_name: "Phone",
  #   is_required: false,
  #   sort_order: 3,
  #   parent_attribute_name: nil,
  #   parent_attribute_value: nil,
  #   test_type_specific_options: nil,
  #   active: true
  # },
  # {
  #   test_type_identifier: {
  #     nlims_code: "NLIMS_TT_0010_MWI",
  #     name: "TB Tests",
  #     short_name: "TB"
  #   },
  #   attribute_name: "District TB Reg No",
  #   is_required: false,
  #   sort_order: 4,
  #   parent_attribute_name: nil,
  #   parent_attribute_value: nil,
  #   test_type_specific_options: nil,
  #   active: true
  # },
  # {
  #   test_type_identifier: {
  #     nlims_code: "NLIMS_TT_0010_MWI",
  #     name: "TB Tests",
  #     short_name: "TB"
  #   },
  #   attribute_name: "HIV Status",
  #   is_required: false,
  #   sort_order: 5,
  #   parent_attribute_name: nil,
  #   parent_attribute_value: nil,
  #   test_type_specific_options: nil,
  #   active: true
  # },
  # {
  #   test_type_identifier: {
  #     nlims_code: "NLIMS_TT_0010_MWI",
  #     name: "TB Tests",
  #     short_name: "TB"
  #   },
  #   attribute_name: "Health Facility",
  #   is_required: false,
  #   sort_order: 7,
  #   parent_attribute_name: nil,
  #   parent_attribute_value: nil,
  #   test_type_specific_options: nil,
  #   active: true
  # }
]

tb_test_type_attributes.each do |tta|
  test_type = TestType.find_by(nlims_code: tta[:test_type_identifier][:nlims_code]) ||
              TestType.find_by(name: tta[:test_type_identifier][:name]) ||

  if test_type.nil?
    puts "Test type not found for identifier: #{tta[:test_type_identifier]}"
    next
  end

  attribute = Attribute.find_by(name: tta[:attribute_name])
  if attribute.nil?
    puts "Attribute not found: #{tta[:attribute_name]}"
    next
  end

  puts "Associating attribute '#{attribute.name}' with test type '#{test_type.name}'"
  test_type_attribute = TestTypeAttribute.find_or_initialize_by(test_type_id: test_type.id, attribute_id: attribute.id)
  test_type_attribute.is_required = tta[:is_required]
  test_type_attribute.sort_order = tta[:sort_order]
  test_type_attribute.parent_attribute = Attribute.find_by(name: tta[:parent_attribute_name]) if tta[:parent_attribute_name]
  test_type_attribute.parent_attribute_value = tta[:parent_attribute_value]
  test_type_attribute.test_type_specific_options = tta[:test_type_specific_options]
  test_type_attribute.active = tta[:active]
  test_type_attribute.save!
  puts "Associated attribute '#{attribute.name}' with test type '#{test_type.name}' successfully."
end
