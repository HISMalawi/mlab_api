class Instrument < RetirableRecord
  validates :name, presence: true, uniqueness: true
  has_many :instrument_test_type_mapping
end
