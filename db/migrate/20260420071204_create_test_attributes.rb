class CreateTestAttributes < ActiveRecord::Migration[7.0]
  def change
    # Generic attributes table - can be used for tests, orders, encounters, etc.
    create_table :attributes do |t|
      t.string :name, null: false
      t.string :label, null: false
      t.text :description
      t.string :field_type, null: false, default: 'text' # text, number, select, radio, checkbox, date, yes_no, textarea
      t.text :options # JSON field for storing select/radio/checkbox options (for select, radio, checkbox types)
      t.boolean :active, default: true

      # Standard fields following mlab_api conventions
      t.integer :voided, default: 0
      t.bigint :voided_by
      t.string :voided_reason
      t.datetime :voided_date
      t.bigint :creator
      t.datetime :created_date
      t.datetime :updated_date
      t.bigint :updated_by

      t.timestamps
    end

    add_index :attributes, :name
    add_index :attributes, :active
    add_index :attributes, :field_type

    # Mapping table: connects attributes to test types with specific configurations
    create_table :test_type_attributes do |t|
      t.references :test_type, foreign_key: true, null: false
      t.references :attribute, foreign_key: true, null: false
      t.boolean :is_required, default: false
      t.integer :sort_order, default: 0

      # For conditional/dependent attributes
      t.references :parent_attribute, foreign_key: { to_table: :attributes }, null: true
      t.string :parent_attribute_value # The value of parent that triggers showing this attribute

      # Override default options if needed for this test type
      t.text :test_type_specific_options

      t.boolean :active, default: true

      # Standard fields
      t.integer :voided, default: 0
      t.bigint :voided_by
      t.string :voided_reason
      t.datetime :voided_date
      t.bigint :creator
      t.datetime :created_date
      t.datetime :updated_date
      t.bigint :updated_by

      t.timestamps
    end

    add_index :test_type_attributes, %i[test_type_id attribute_id],
              unique: true,
              where: 'voided = 0',
              name: 'index_test_type_attrs_on_test_type_and_attr'
    add_index :test_type_attributes, :active
    add_index :test_type_attributes, %i[test_type_id active]

    # Stores actual attribute values for specific tests
    create_table :test_attribute_values do |t|
      t.references :test, foreign_key: true, null: false
      t.references :attribute, foreign_key: true, null: false
      t.text :value # Store the actual value entered/selected

      # Standard fields
      t.integer :voided, default: 0
      t.bigint :voided_by
      t.string :voided_reason
      t.datetime :voided_date
      t.bigint :creator
      t.datetime :created_date
      t.datetime :updated_date
      t.bigint :updated_by

      t.timestamps
    end

    add_index :test_attribute_values, %i[test_id attribute_id], name: 'index_test_attr_values_on_test_and_attr'
  end
end
