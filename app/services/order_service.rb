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
      destination = params[:encounter][:facility_section] if encounterType.name == 'Referral'
      Encounter.create!(
        client_id:,
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
      priority_id = Priority.find_by(id: order_params[:priority])&.id
      priority_id ||= Priority.first&.id
      Order.create!(
        encounter_id:,
        priority_id:,
        accession_number:,
        tracking_number:,
        sample_collected_time: s_collection_time,
        requested_by: order_params[:requested_by],
        collected_by: order_params[:collected_by]
      )
    end

    def create_test(order_id, test_params, lab_location)
      lab_location_id = lab_location.present? ? lab_location.to_i : 1
      test_params.each do |test_param|
        test_type = TestType.find_by_name(test_param[:test_type])
        test_panel = TestPanel.find_by_name(test_param[:test_type])
        specimen_id = test_param[:specimen]
        if test_panel.nil?
          find_or_create_test(specimen_id, order_id, test_type, test_panel&.id, lab_location_id)
        else
          member_test_types = TestTypePanelMapping.joins(:test_type).where(test_panel_id: test_panel.id).pluck('test_types.id')
          member_test_types.each do |test_type_id|
            test_type = TestType.find_by_id(test_type_id)
            find_or_create_test(specimen_id, order_id, test_type, test_panel&.id, lab_location_id)
          end
        end
      end
    end

    def find_or_create_test(specimen_id, order_id, test_type, test_panel_id, lab_location_id)
      status_ids = Status.where(name: %w[pending started completed]).ids
      test = Test.find_by(specimen_id:, order_id:, test_type_id: test_type.id, test_panel_id:, lab_location_id:)
      if test.nil?
        return Test.create!(specimen_id:, order_id:, test_type_id: test_type.id, test_panel_id:, lab_location_id:)
      end

      if test_type.name.downcase == 'cross-match'
        return Test.create!(specimen_id:, order_id:, test_type_id: test_type.id, test_panel_id:, lab_location_id:)
      end
      return if status_ids.include?(test.status_id)

      Test.create!(specimen_id:, order_id:, test_type_id: test_type.id, test_panel_id:, lab_location_id:)
    end

    def add_test_to_order(order_id, tests, lab_location)
      create_test(order_id, tests, lab_location)
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
      ClientManagement::ClientService.client(encounter.client_id).merge({
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
                                                                          order_status_id: order.status_id,
                                                                          order_status_name: Status.where(id: order.status_id).first&.name,
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
      default_accession_number_length = config_data['default'].nil? ? true : config_data['default']['accession_number_length']
      zero_padding = 6 unless default_accession_number_length
      mutex = Mutex.new if mutex.blank?
      mutex.lock
      max_acc_num = 0
      code = GlobalService.current_location['code']
      year = Time.current.year.to_s.last(2)
      record = begin
        Order.where.not(accession_number: nil).order(id: :desc).limit(1).last.accession_number
      rescue StandardError
        nil
      end
      if record.blank?
        max_acc_num = 1
      else
        max_acc_num = record.to_s.gsub(code, '').to_i
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
