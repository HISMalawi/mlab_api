class SpecimenLifespan < ActiveRecord::Migration[7.0]
  def change
    add_column :specimen_test_type_mappings, :life_span, :integer, after: :test_type_id
    ActiveRecord::Base.connection.execute("ALTER table specimen_test_type_mappings add column life_span_units enum('mins',
      'hours',
      'days', 'months') after life_span;")
  end
end
