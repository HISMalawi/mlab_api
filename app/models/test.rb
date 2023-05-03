class Test < VoidableRecord
  belongs_to :specimen
  belongs_to :order
  belongs_to :test_type
  has_many :test_status

  after_create :create_default_status

  def as_json(options = {})
    unless options[:methods].present?
      return super(options.merge(methods: %i[indicators request_origin requesting_ward specimen_type accession_number tracking_number requested_by test_type_name status]))
    end
    super(options.merge(methods: %i[indicators request_origin requesting_ward specimen_type accession_number tracking_number requested_by test_type_name expected_turn_around_time client status]))
  end

  def short_name
    test_type.short_name
  end

  def create_default_status
    TestStatus.create(test_id: id, status_id: Status.find_by_name('pending').id, creator: User.current.id)
  end

  def indicators
    test_type.test_indicators.as_json(only: %i[id name test_indicator_type])
      .map { |i| i.merge(result: results(i['id'])) }
  end

  def results(indicator_id)
    TestResult.where(test_id: id, test_indicator_id: indicator_id)&.last&.as_json(only: %i[id value result_date])
  end

  def request_origin
    EncounterType.find(order.encounter.encounter_type_id).name
  end

  def requesting_ward
    order.encounter.facility_section.name
  end

  def specimen_type
    specimen&.name
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

  def client
    order.encounter.client.person.as_json(only: %i[id first_name middle_name last_name sex date_of_birth birth_date_estimated])
  end
end
