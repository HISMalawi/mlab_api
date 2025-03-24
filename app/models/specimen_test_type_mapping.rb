# frozen_string_literal: true

# Model for SpecimenTestTypeMappings table
class SpecimenTestTypeMapping < RetirableRecord
  belongs_to :specimen
  belongs_to :test_type
end
