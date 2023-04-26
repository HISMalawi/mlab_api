class Test < VoidableRecord
  belongs_to :specimen
  belongs_to :order
  belongs_to :test_type
  has_many :test_status

  def as_json(options= {})
    super(options.merge(methods: %i[accession_number tracking_number requested_by test_type_name expected_turn_around_time patient_name status]))
  end

  def status
    test_status&.last&.status&.name
  end

  def accession_number
    order.accession_number
  end

  def tracking_number
    order.tracking_number
  end

  def requested_by
    order.requested_by
  end

  def test_type_name
    test_type.name
  end

  def test_type_short_name
    test_type.short_name
  end

  def expected_turn_around_time
    test_type.expected_turn_around_time
  end

  def patient_name
    order.encounter.client.person.fullname
  end
end
