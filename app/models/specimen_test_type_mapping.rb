class SpecimenTestTypeMapping < RetirableRecord
  belongs_to :specimen
  belongs_to :test_type
end
