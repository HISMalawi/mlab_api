# frozen_string_literal: true

# Model for TestTypeOrganismMappings table
class TestTypeOrganismMapping < RetirableRecord
  belongs_to :test_type
  belongs_to :organism
end
