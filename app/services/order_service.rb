module OrderService
  class << self
    # TO DO: IMPLEMENT PARAMS VALIDATIONS

    def create_encounter(params)
      client_id = params[:client][:id]
      if client_id.blank?
        client_params = {
          client: params[:client],
          person: params[:person]
        }
      client = ClientManagement::ClientService.create_client(client_params, params[:client_identifiers])
      client_id = client.id
      end
      # facility = Facility.find_or_create_by!(name: params[:sending_facility]
      facility = params[:encounter][:sending_facility]
      # facility_section = FacilitySection.find_or_create_by!(name: params[:facility_section])
      facility_section = params[:encounter][:facility_section]
      visit_type = VisitType.find(params[:encounter][:visit_type])
      destination = facility
      if visit_type.name == 'Referal'
        destination = params[:encounter][:destination_facility]
      end
      Encounter.create!(
        client_id: client_id,
        facility_id: facility,
        destination_id: destination,
        facility_section_id: facility_section,
        start_date: Time.now
      )
    end

    def create_order(encounter_id, order_params)
      accession_number = generate_accession_number
      tracking_number = order_params[:tracking_number].blank? ? "X#{accession_number}" : order_params[:tracking_number]
      Order.create!(
        encounter_id: encounter_id,
        priority_id: order_params[:priority],
        accession_number: accession_number,
        tracking_number: tracking_number,
        sample_collected_time: order_params[:sample_collected_time],
        requested_by: order_params[:requested_by],
        collected_by: order_params[:collected_by]
      )
    end

    def create_test(order_id, test_params)
      # TO DO: HANDLE TEST PANELS
      test_params.each do |test_param|
        Test.create!(
          specimen_id: test_param[:specimen],
          order_id: order_id,
          test_type_id: test_param[:test_type]
        )
      end
    end

    def show_order(order, encounter)
      tests = Test.where(order_id: order.id)
      serialize_order(order, encounter, tests)
    end

    def serialize_order(order, encounter, tests)
      ClientManagement::ClientService.get_client(encounter.client_id).merge({
        accession_number: order.accession_number,
        tracking_number: order.tracking_number,
        requested_by: order.requested_by,
        collected_by: order.collected_by,
        registered_by: User.find(order.creator).username,
        priority: order.priority.name,
        tests: serialize_test(tests)
      })
    end

    def serialize_test(tests)
      tests_ = []
      tests.each do |test|
        tests_ << {
          specimen: test.specimen.name,
          test_type: test.test_type.name
        }
      end
      tests_
    end

    def generate_accession_number
      zero_padding = 8
      year = Time.current.year.to_s.last(2)
      order_id = User.last.id.to_s.rjust(zero_padding, '0')
      side_code = 'KCH'
      "#{side_code}#{year}#{order_id}"
    end

  end
end