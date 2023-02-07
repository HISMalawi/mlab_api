class SpecimenTestTypeMapping < ApplicationRecord
  belongs_to :specimen
  belongs_to :test_type
end
