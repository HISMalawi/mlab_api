class Instrument < RetirableRecord
  validates :name, presence: true, uniqueness: true
  has_many :instrument_test_type_mapping
  has_many :test_types, through: :instrument_test_type_mapping

  def as_json(options = {})
    super(options.merge({ only: %i[id name description ip_address hostname can_perform created_date], methods: %i[supported_tests] }))
  end



  def supported_tests
    test_types.select(
      'test_types.id',
      'test_types.name'
    )
  end
end
