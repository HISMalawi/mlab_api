class Instrument < RetirableRecord
  validates :name, presence: true, uniqueness: true
  has_many :instrument_test_type_mapping

  def as_json(options = {})
    super(options.merge({ only: %i[id name description ip_address hostname can_perform created_date] }))
  end
end
