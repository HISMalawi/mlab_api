module OrderService
  class << self
    # TO DO: IMPLEMENT PARAMS VALIDATIONS

    def create(params)
      ActiveRecord::Base.transaction do
        @encounter = OrderService.create_encounter(params)
        @order = OrderService.create_order(@encounter.id, params[:order])
        OrderService.create_test(@order.id, params[:tests], params[:lab_location])
      end
      @order
    end

    def add_order(params)
      ActiveRecord::Base.transaction do
        @order = OrderService.create_order(params[:encounter_id], params[:order])
        OrderService.create_test(@order.id, params[:tests], params[:lab_location])
      end
      @order
    end

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
        encounter_type_id: encounterType.id,
        client_history: params[:encounter][:client_history]
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
      lab_location_id = lab_location.present? && (lab_location != '0' || lab_location != 0) ? lab_location.to_i : LabLocation.first&.id
      test_params.each do |test_param|
        test_type = TestType.find_by(preferred_name: test_param[:test_type]) || TestType.find_by_name(test_param[:test_type])
        test_panel = TestPanel.find_by(preferred_name: test_param[:test_type]) || TestPanel.find_by_name(test_param[:test_type])
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
      default_length = AppSetting.find_by(name: 'default_accession_number_length')&.value || 10
      zero_padding = default_length.to_i - 2
      code = GlobalService.current_location['code']
      year = Time.current.year.to_s.last(2)
      accession_number = nil
      retries = 0
      max_attempts = 3
      begin
        AccessionNumberTracker.transaction do
          # Get the maximum sequence number for current year and location
          max_acc_num = get_next_sequence_number(code, year)
          # Safety counter to prevent infinite loops
          attempts = 0
          max_loop_attempts = 100
          loop do
            attempts += 1
            if attempts > max_loop_attempts
              raise "Unable to generate unique accession number after #{max_loop_attempts} attempts"
            end

            padded = max_acc_num.to_s.rjust(zero_padding, '0')
            accession_number = "#{code}#{year}#{padded}"
            # Check if the number exists in either table
            if number_exists?(accession_number)
              max_acc_num += 1
              max_acc_num += 100 if attempts == (max_loop_attempts - 60)
              max_acc_num = get_next_sequence_number(code, year, order: true) if attempts == (max_loop_attempts - 70)
              max_acc_num += 2500 if attempts == (max_loop_attempts - 80)
              next
            else
              # Create the new tracker record
              AccessionNumberTracker.create!(accession_number: accession_number)
              # Clean up old records (optional: keep last N records instead of just 1)
              cleanup_old_records
              break
            end
          end
        end
      rescue ActiveRecord::RecordNotUnique => e
        retries += 1
        unless retries < max_attempts
          raise "Failed to generate unique accession number after #{max_attempts} attempts: #{e.message}"
        end

        # Add small random delay to reduce contention
        sleep(rand(0.01..0.05))
        retry
      rescue StandardError => e
        raise "Error generating accession number: #{e.message}"
      end
      accession_number
    end

    def get_next_sequence_number(code, year, order: false)
      # Try to get the last record for this year/location combination first
      current_year_record = AccessionNumberTracker
                            .lock
                            .where('accession_number LIKE ?', "#{code}#{year}%")
                            .order(:id)
                            .last
      if order
        current_year_record = Order
                            .lock
                            .where('accession_number LIKE ?', "#{code}#{year}%")
                            .last
      end
      if current_year_record
        # Extract sequence number from current year record
        sequence_part = current_year_record.accession_number.gsub(/^#{Regexp.escape(code)}#{year}/, '')
        return sequence_part.to_i + 1
      end
      # Fallback: check the very last record for year rollover logic
      last_record = AccessionNumberTracker.lock.order(:id).last
      return 1 if last_record.blank?

      # Parse the last record to determine if we're in a new year
      record_number = last_record.accession_number
      # Remove location code to get year + sequence
      year_and_seq = record_number.gsub(/^#{Regexp.escape(code)}/, '')
      if year_and_seq.length >= 2
        record_year = year_and_seq[0, 2].to_i
        # If current year is greater, start from 1, otherwise continue sequence
        return 1 if year.to_i > record_year

        # Extract sequence number (everything after the 2-digit year)
        sequence_part = year_and_seq[2..-1] || '0'
        return sequence_part.to_i + 1

      end

      # Fallback if parsing fails
      1
    end

    def number_exists?(accession_number)
      # Check both Order and AccessionNumberTracker tables
      Order.exists?(accession_number: accession_number) ||
        AccessionNumberTracker.exists?(accession_number: accession_number)
    end

    def cleanup_old_records
      # Keep only the last record, destroy older ones
      # Alternative: keep last N records for audit purposes
      # If you want to keep the last N records, adjust the limit accordingly
      old_records = AccessionNumberTracker.order(:id).offset(2)
      old_records.delete_all if old_records.exists?
    end

    def add_order_dto(encounter_id, test_params, lab_location)
      previous_order = Order.where(encounter_id:).last
      {
        encounter_id:,
        order: {
          priority: previous_order&.priority_id,
          requested_by: previous_order&.requested_by,
          collected_by: previous_order&.collected_by,
          sample_collected_time: previous_order&.sample_collected_time,
          tracking_number: ''
        },
        tests: test_params,
        lab_location:
      }
    end
  end
end
