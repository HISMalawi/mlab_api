class Order < VoidableRecord
  belongs_to :encounter
  belongs_to :priority
  has_many :tests
  has_many :client_order_print_trails

  after_create :create_default_status

  def create_default_status
    OrderStatus.create!(order_id: id, status_id: Status.find_by_name('specimen-not-collected').id, creator: User.current.id)
  end

  def as_json(options = {})
    specimen_test_type = specimen_test_type()
    super(options).merge({
      specimen: specimen_test_type[:specimen],
      test_types: specimen_test_type[:test_types],
      order_status: order_status,
      print_count: print_count,
      order_status_trail: order_status_trail,
      request_origin: request_origin,
      requesting_ward: requesting_ward,
      tests: order_tests
    }).as_json
  end

  def order_tests
    tests.as_json({client_report: true})
  end

  def specimen_test_type
    specimen = []
    test_types = []
    tests.each do |test|
      specimen.push(test.specimen.name)
      test_t = test.test_type.short_name.blank? ? test.test_type.name : test.test_type.short_name
      test_types.push({
        name: test_t
      })
    end
    {
      test_types: test_types,
       specimen: specimen.uniq.join(", ")
    }
  end

  def order_status
    OrderStatus.where(order_id: id)&.last&.status&.name
  end

  def order_status_trail
    OrderStatus.where(order_id: id)
  end

  def request_origin
    EncounterType.find(encounter.encounter_type_id).name
  end

  def print_count
    client_order_print_trails.count
  end

  def requesting_ward
    ward = encounter.facility_section
    ward.nil? ? '' : ward.name
  end
  
end
