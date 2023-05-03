class SpecimenLifespan < ActiveRecord::Migration[7.0]
  def change
    add_column :specimen_test_type_mappings, :life_span, :integer
  end
end
