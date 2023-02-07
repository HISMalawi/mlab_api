class InstrumentTestTypeMapping < ApplicationRecord
  belongs_to :instrument
  belongs_to :test_type
end
