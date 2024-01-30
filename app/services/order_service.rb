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
      g = Global.find(params[:encounter][:sending_facility])
      facility = Facility.find_or_create_by!(name: g.name).id
      facility_section = params[:encounter][:facility_section]
      encounterType = EncounterType.find(params[:encounter][:encounter_type])
      destination = facility
      if encounterType.name == 'Referral'
        destination = params[:encounter][:facility_section]
      end
      Encounter.create!(
        client_id: client_id,
        facility_id: facility,
        destination_id: destination,
        facility_section_id: facility_section,
        start_date: Time.now,
        encounter_type_id: encounterType.id
      )
    end

    def create_order(encounter_id, order_params)
      accession_number = generate_accession_number
      tracking_number = order_params[:tracking_number].blank? ? "X#{accession_number}" : order_params[:tracking_number]
      s_collection_time = order_params[:sample_collected_time].blank? ? Time.now : order_params[:sample_collected_time]
      Order.create!(
        encounter_id: encounter_id,
        priority_id: order_params[:priority],
        accession_number:,
        tracking_number:,
        sample_collected_time: s_collection_time,
        requested_by: order_params[:requested_by],
        collected_by: order_params[:collected_by]
      )
    end

    def create_test(order_id, test_params)
      test_params.each do |test_param|
        test_type = TestType.find_by_name(test_param[:test_type])
        test_panel = TestPanel.find_by_name(test_param[:test_type])
        if test_panel.nil?
          Test.find_or_create_by!(
            specimen_id: test_param[:specimen],
            order_id: order_id,
            test_type_id: test_type.id
          )
        else
          member_test_types = TestTypePanelMapping.joins(:test_type).where(test_panel_id: test_panel.id).pluck('test_types.id')
          member_test_types.each do |test_type|
            Test.find_or_create_by!(
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
        registered_by: User.find(order.creator)&.username,
        priority: order.priority.name,
        sending_facility: encounter.facility&.name,
        destination_facility: encounter.destination&.name,
        date_created: order.created_date,
        tests: serialize_test(tests)
      })
    end

    def serialize_test(tests)
      tests_ = []
      tests.each do |test|
        tests_ << {
          specimen_id: test.specimen.id,
          specimen: test.specimen.name,
          test_type: test.test_type.name,
          test_type_short_name: test.test_type.short_name
        }
      end
      tests_
    end

    def generate_accession_number
      zero_padding = 8
      config_data = YAML.load_file("#{Rails.root}/config/application.yml")
      default_accession_number_length = config_data['default'].nil? ? true : config_data['default']["accession_number_length"]
      zero_padding = 6 unless default_accession_number_length
      mutex = Mutex.new if mutex.blank?
      mutex.lock
      max_acc_num = 0
      code = GlobalService.current_location['code']
      year = Time.current.year.to_s.last(2)
      record = Order.where.not(accession_number: nil).order(id: :desc).limit(1).last.accession_number rescue nil
      if record.blank?
        max_acc_num = 1
      else
        max_acc_num = record.match(/\d+/)[0].to_i
        max_acc_num += 1
        max_yr = max_acc_num.to_s.slice!(0, 2).to_i
        max_acc_num = year.to_i > max_yr ? 1 : max_acc_num.to_s[2..].to_i
      end
      max_acc_num = max_acc_num.to_i.to_s.rjust(zero_padding, '0')
      mutex.unlock
      "#{code}#{year}#{max_acc_num}"
    end
  end
end
