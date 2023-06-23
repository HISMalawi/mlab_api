class Test < VoidableRecord
  belongs_to :specimen
  belongs_to :order
  belongs_to :test_type

  has_many :test_status
  has_one :current_test_status
  belongs_to :test_panel, optional: true

  after_create :create_default_status

  def as_json(options = {})
    if options[:client_report]
      methods = %i[status indicators culture_observation test_type_name print_device expected_turn_around_time suscept_test_result status_trail]
    else
      methods = %i[test_panel_name request_origin requesting_ward specimen_type accession_number  completed_by
        tracking_number requested_by test_type_name client status order_status]
      unless options[:minimal]
        methods.concat %i[indicators culture_observation expected_turn_around_time suscept_test_result status_trail is_machine_oriented order_status_trail]
      end
    end
    super(options.merge(methods: methods))
  end

  def short_name
    test_type.short_name
  end

  def is_machine_oriented
    !InstrumentTestTypeMapping.where(test_type_id: test_type.id).empty?
  end

  def create_default_status
    TestStatus.create(test_id: id, status_id: Status.find_by_name('pending').id, creator: User.current.id)
  end

  def indicators
    test_type.test_indicators.as_json(only: %i[id name test_indicator_type unit description])
      .map do |i|
        i.merge!(result: results(i['id']))
        i.merge!(indicator_ranges: indicator_ranges(i['id']))
      end
  end

  def results(indicator_id)
    TestResult.where(test_id: id, test_indicator_id: indicator_id)&.last&.as_json(only: %i[id value result_date machine_name])
  end

  def indicator_ranges(indicator_id)
    TestIndicatorRange.where(test_indicator_id: indicator_id)
  end

  def request_origin
    encounter_type = EncounterType.find_by(id: order.encounter.encounter_type_id)
    encounter_type.nil? ? '' : encounter_type.name
  end

  def requesting_ward
    ward = order.encounter.facility_section
    ward.nil? ? '' : ward.name
  end

  def status_trail
    TestStatus.where(test_id: id)
  end

  def test_panel_name
    test_panel_id.nil? ? nil : test_panel.name
  end

  def order_status_trail
    OrderStatus.where(order_id: order.id)
  end

  def completed_by
    status_trail = status_trail()
    c = {}
    status_trail.each do |status|
      if status.status_id == 4
        user = User.find_by_id(status.creator)
        c[:id] = user.id
        c[:username] =  user.username
        c[:is_super_admin] = is_super_admin?(user)
        c[:status_id] = status.status_id
      end
    end
    c
  end

  def is_super_admin?(user)
    roles = UserRoleMapping.where(user_id: user.id)
    is_super_admin = false
    roles.as_json.each do |role|
      if role["role_name"] == "Superuser" || role['role_name'] == 'Superadmin'
        is_super_admin = true
        break
      end
    end
    is_super_admin
  end

  def specimen_type
    specimen&.name
  end

  def status
    test_status&.order(created_date: :desc)&.first&.status&.name
  end

  def order_status
    OrderStatus.where(order_id: order.id).order(created_date: :desc)&.last&.status&.name
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

  def print_device
    test_type.print_device
  end

  def test_type_short_name
    test_type.short_name
  end

  def expected_turn_around_time
    test_type.expected_turn_around_time
  end

  def client
    order_ = order.encounter.client.person.as_json(only: %i[id first_name middle_name last_name sex date_of_birth birth_date_estimated])
    order_['id'] = order.encounter.client.id
    order_
  end

  def suscept_test_result
    Tests::CultureSensivityService.get_drug_susceptibility_test_results(id)
  end

  def culture_observation
    Tests::CultureSensivityService.culture_observation(id)
  end
end
