class InstrumentTestTypeMapping < RetirableRecord
  belongs_to :instrument
  belongs_to :test_type
end
