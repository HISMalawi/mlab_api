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
      facility = params[:encounter][:sending_facility]
      facility_section = params[:encounter][:facility_section]
      encounterType = EncounterType.find(params[:encounter][:encounter_type])
      destination = facility
      if encounterType.name == 'Referal'
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
      test_params.each do |test_param|
        test_type = TestType.find_by_name(test_param[:test_type])
        test_panel = TestPanel.find_by_name(test_param[:test_type])
        if test_panel.nil?
          Test.create!(
            specimen_id: test_param[:specimen],
            order_id: order_id,
            test_type_id: test_type.id
          )
        else
          member_test_types = TestTypePanelMapping.joins(:test_type).where(test_panel_id: test_panel.id).pluck('test_types.id')
          member_test_types.each do |test_type|
            Test.create!(
              specimen_id: test_param[:specimen],
              order_id: order_id,
              test_type_id: test_type,
              test_panel_id: test_panel.id
            )
          end
        end
      end
    end

    def add_test_to_order(order_id, tests)
      create_test(order_id, tests)
      Order.find(order_id)
    end

    def search_by_accession_or_tracking_number(search_query)
      Order.where(accession_number: search_query).or(Order.where(tracking_number: search_query)).first
    end

    def show_order(order, encounter)
      tests = Test.where(order_id: order.id)
      serialize_order(order, encounter, tests)
    end

    def serialize_order(order, encounter, tests)
      ClientManagement::ClientService.get_client(encounter.client_id).merge({
        order_id: order.id,
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
          specimen_id: test.specimen.id,
          specimen: test.specimen.name,
          test_type: test.test_type.name
        }
      end
      tests_
    end

    def generate_accession_number
      zero_padding = 8
      year = Time.current.year.to_s.last(2)
      order_id = Order.last.id.to_s.rjust(zero_padding, '0')
      side_code = GlobalService.current_location
      "#{side_code['code']}#{year}#{order_id}"
    end

  end
end