Rails.logger = Logger.new(STDOUT)
module Nlims
  module Sync
    @nlims_cache = { token: nil, expires_at: nil, base_url: nil, enable_real_time_sync: nil, ping: false }
    def self.create_order(id: nil)
      nlims = nlims_token
      return if nlims[:token].blank?

      orders =  Order.find_by_sql(
        "SELECT o.id, o.encounter_id, o.tracking_number, o.sample_collected_time,
                    o.collected_by, o.requested_by , o.created_date , o.updated_date, o.priority_id,
                    o.creator
                  FROM orders o
                  INNER JOIN unsync_orders uo ON
                    uo.test_or_order_id = o.id
                  WHERE uo.data_level = 'order' AND uo.data_not_synced ='new order' AND uo.sync_status = 0
                  #{id_condition(id)}
                  ORDER BY uo.id DESC LIMIT 500"
      )
      facility_details = GlobalService.current_location
      orders.each do |order|
        Rails.logger.info("=======Creating order #{order&.tracking_number} in nlims =============")
        tests = Test.where(order_id: order[:id])
        next if tests.empty?

        specimen_type = tests.first&.specimen_type
        next if specimen_type.nil?

        person_creator = Person.find_by(id: User.find_by(id: order[:creator])&.person_id)
        priority = Priority.find(order[:priority_id]).name
        encounter = Encounter.find(order[:encounter_id])
        client = encounter.client.person
        payload = {
          tracking_number: order[:tracking_number],
          date_sample_drawn: order[:sample_collected_time].blank? ? order[:created_date] : order[:sample_collected_time],
          date_received: order[:created_date],
          health_facility_name: facility_details[:name],
          district: facility_details[:district],
          target_lab: facility_details[:name],
          requesting_clinician: order[:requested_by],
          return_json: 'true',
          sample_type: specimen_type,
          tests: tests.joins(:test_type).pluck('test_types.name'),
          sample_status: OrderStatus.where(order_id: order[:id]).order(created_date: :asc).first.status.name.gsub('-',
                                                                                                                  '_'),
          sample_priority: priority,
          reason_for_test: priority,
          order_location: encounter.facility_section.name,
          who_order_test_id: nil,
          who_order_test_last_name: person_creator&.last_name || '',
          who_order_test_first_name: person_creator&.first_name || '',
          who_order_test_phone_number: '',
          first_name: client[:first_name],
          last_name: client[:last_name],
          middle_name: client[:middle_name],
          date_of_birth: client[:date_of_birth],
          gender: client[:sex] == 'F' ? 1 : 0,
          patient_residence: '',
          patient_location: '',
          patient_town: '',
          patient_district: '',
          national_patient_id: '',
          phone_number: '',
          art_start_date: ''
        }
        response = RestClient::Request.execute(
          method: :post,
          url: "#{nlims[:base_url]}/api/v1/create_order/",
          headers: { content_type: :json, accept: :json, 'token': "#{nlims[:token]}" },
          payload: payload.to_json
        )
        response = JSON.parse(response.body)
        if response['error'] == false && response['message'] == 'order created successfuly' || response['message'] == 'order already available'
          unsync_order = UnsyncOrder.where(sync_status: 0, data_not_synced: 'new order',
                                           test_or_order_id: order[:id]).first
          update_unsync_order(unsync_order)
          Rails.logger.info("=======Successfully created orders in nlims:#{payload[:tracking_number]}=============")
        else
          Rails.logger.error("=============#{response['message']}:#{payload[:tracking_number]}===================")
        end
      end
    end

    def self.create_order_v2(id: nil, once_off: false)
      nlims = nlims_token
      return if nlims[:token].blank?

      orders = Order.find_by_sql(
        "SELECT o.id, o.encounter_id, o.tracking_number, o.sample_collected_time,
            o.collected_by, o.requested_by , o.created_date , o.updated_date, o.priority_id,
            o.creator, o.status_id
          FROM orders o
          INNER JOIN unsync_orders uo ON
            uo.test_or_order_id = o.id
          WHERE uo.data_level = 'order' AND uo.data_not_synced ='new order' AND uo.sync_status = 0
          #{id_condition(id)}
          ORDER BY uo.id DESC LIMIT 500"
      )
      Parallel.each(orders, in_threads: 4) do |order_record|
        Rails.logger.info("=======Creating order #{order_record&.tracking_number} in nlims =============")
        order = Order.find_by(id: order_record&.id)
        next if order.nil?
        next unless order.tests&.present?

        payload = order_payload(order)
        url = once_off ? "#{nlims[:base_url]}/api/v2/create_order_once_off/" : "#{nlims[:base_url]}/api/v2/orders/"
        begin
          response = RestClient::Request.execute(
            method: :post,
            url:,
            headers: { content_type: :json, accept: :json, 'token': nlims[:token].to_s },
            payload: payload.to_json
          )
          response = JSON.parse(response.body)
          if response['error'] == false && ['order created successfully', 'order created successfuly',
                                            'order already available'].include?(response['message'])
            unsync_order = UnsyncOrder.where(sync_status: 0, data_not_synced: 'new order',
                                             test_or_order_id: order_record&.id).first
            update_unsync_order(unsync_order)
            Rails.logger.info("=======Successfully created orders in nlims:#{payload[:order][:tracking_number]}=============")
          else
            Rails.logger.error("=============#{response}:#{payload[:order][:tracking_number]}===================")
            raise StandardError, "Failed to create order in nlims: #{response['message']}"
          end
        rescue StandardError => e
          Rails.logger.error("=======#{e.message}:#{payload[:order][:tracking_number]}=============")
          next
        end
      end
    end

    def self.update_order(id: nil)
      nlims = nlims_token
      return if nlims[:token].blank?

      orders = Order.find_by_sql("
        SELECT o.tracking_number , cos.name AS status, cos.creator AS updater, uo.test_or_order_id AS id, o.updated_date AS updated_date
        FROM unsync_orders uo
        INNER JOIN current_order_status cos ON cos.order_id = uo.test_or_order_id
        INNER JOIN orders o ON uo.test_or_order_id = o.id
        WHERE uo.data_level = 'order' AND (uo.data_not_synced = 'specimen-accepted' OR uo.data_not_synced = 'specimen-rejected')
          AND uo.sync_status = 0 #{id_condition(id)} LIMIT 100
        ")
      orders.each do |order|
        Rails.logger.info('=======Updating orders in nlims=============')
        payload = {
          tracking_number: order[:tracking_number],
          status: order.status.gsub('-', '_'),
          time_updated: OrderStatus.find_by(order_id: order[:id], status_id: Status.find_by(name: order[:status]).id)
                                   &.created_date || order[:updated_date],
          status_trail: OrderStatus.where(order_id: order[:id]).map do |trail|
            person_creator = Person.find_by(id: User.find_by(id: trail&.creator)&.person_id)
            {
              status: trail&.status&.name&.gsub('-', '_'),
              timestamp: trail&.created_date,
              updated_by: {
                first_name: person_creator&.first_name,
                last_name: person_creator&.last_name,
                id: person_creator&.id,
                phone_number: nil
              }
            }
          end
        }
        begin
          response = RestClient::Request.execute(
            method: :put,
            url: "#{nlims[:base_url]}/api/v2/orders/#{order[:tracking_number]}",
            headers: { content_type: :json, accept: :json, 'token': "#{nlims[:token]}" },
            payload: payload.to_json
          )
          response = JSON.parse(response.body)
          if response['error'] == false && ['order updated successfuly', 'order updated successfully'].include?(response['message'])
            unsync_order = UnsyncOrder.where(sync_status: 0, data_not_synced: order[:status],
                                             test_or_order_id: order[:id]).first
            update_unsync_order(unsync_order)
            Rails.logger.info("=======Successfully updated orders in nlims: #{payload[:tracking_number]}=============")
          else
            Rails.logger.info("=======#{response['message']}:#{payload[:tracking_number]}=============")
            raise StandardError, response['message']
          end
        rescue StandardError => e
          Rails.logger.error("=======#{e.message}:#{payload[:tracking_number]}=============")
          next
        end
      end
    end

    def self.update_test(id: nil)
      nlims = nlims_token
      return if nlims[:token].blank?

      tests = Test.find_by_sql("
          SELECT
            o.id AS order_id, t.id AS test_id, o.tracking_number , uo.data_not_synced AS test_status,
            uo.creator AS creator, uo.updated_date, uo.id
          FROM
            unsync_orders uo
          INNER JOIN tests t ON t.id = uo.test_or_order_id
          INNER JOIN orders o ON t.order_id  = o.id
          WHERE
            uo.data_level = 'test' AND uo.sync_status = 0 #{id_condition(id)} ORDER BY uo.id DESC LIMIT 100
      ")
      tests.each do |test_res|
        Rails.logger.info('=======Updating tests in nlims=============')
        test_ = Test.where(id: test_res[:test_id]).first
        test_name = test_.test_type_name
        updater = User.where(id: test_res[:creator])
        updater = if updater.empty?
                    {
                      first_name: '',
                      last_name: ''
                    }
                  else
                    updater.first.person
                  end
        first_name = updater[:first_name]
        last_name = updater[:last_name]
        result_date = test_res[:updated_date]
        test_status = test_res[:test_status].gsub('-', '_')
        test_status = 'verified' if test_status == 'result'
        result_date = '' unless test_status == 'verified'
        payload = {
          tracking_number: test_res[:tracking_number],
          test_status:,
          test_name:,
          result_date:,
          who_updated: {
            first_name:,
            last_name:,
            id: updater[:id]
          }
        }
        if %w[result verified].include?(test_res[:test_status])
          test_results = TestResult.joins(:test_indicator).where(test_id: test_res[:test_id])
                                   .where.not(value: '').where.not(value: nil)
                                   .select('test_indicators.name AS test_indicator, test_results.value AS result_value, test_results.id')
          results = {}
          unless test_results.empty?
            test_results.each do |test_result|
              test_indicator = test_result[:test_indicator]
              test_indicator = 'Epithelial cells' if test_indicator == 'Epithelial cell'
              test_indicator = 'Casts' if test_indicator == 'Cast'
              test_indicator = 'Yeast cells' if test_indicator == 'Yeast cell'
              test_indicator = 'Hepatitis B' if test_indicator == 'HepB'
              results[test_indicator] = test_result[:result_value]
            end
          end
          payload[:results] = results
        end
        response = RestClient::Request.execute(
          method: :post,
          url: "#{nlims[:base_url]}/api/v1/update_test/",
          headers: { content_type: :json, accept: :json, 'token': "#{nlims[:token]}" },
          payload: payload.to_json
        )
        response = JSON.parse(response.body)
        if response['error'] == false && response['message'] == 'test updated successfuly'
          unsync_order = UnsyncOrder.where(sync_status: 0, data_not_synced: test_res[:test_status],
                                           test_or_order_id: test_res[:test_id]).first
          update_unsync_order(unsync_order)
          Rails.logger.info("=======Successfully updated tests in nlims:#{payload[:tracking_number]}=============")
        else
          Rails.logger.error("=============#{response['message']}:#{payload[:tracking_number]}===================")
        end
      end
    end

    def self.update_test_v2(id: nil)
      nlims = nlims_token
      return if nlims[:token].blank?

      tests = Test.find_by_sql("
          SELECT
            o.id AS order_id, t.id AS test_id, o.tracking_number, uo.data_not_synced AS test_status,
            uo.creator AS creator, uo.updated_date, uo.id
          FROM
            unsync_orders uo
          INNER JOIN tests t ON t.id = uo.test_or_order_id
          INNER JOIN orders o ON t.order_id = o.id
          WHERE
            uo.data_level = 'test' AND uo.sync_status = 0 #{id_condition(id)}
          ORDER BY uo.id DESC LIMIT 100
      ")

      GlobalService.current_location

      tests.each do |test_res|
        Rails.logger.info("=======Updating test #{test_res[:test_id]} in nlims =============")

        payload = test_payload(Test.find_by(id: test_res[:test_id]))
        begin
          response = RestClient::Request.execute(
            method: :put,
            url: "#{nlims[:base_url]}/api/v2/tests/#{payload[:tracking_number]}",
            headers: { content_type: :json, accept: :json, 'token': nlims[:token].to_s },
            payload: payload.to_json
          )

          response = JSON.parse(response.body)
          if response['error'] == false && response['message'] == 'test updated successfuly'
          unsync_order = UnsyncOrder.where(
            sync_status: 0,
            data_not_synced: test_res[:test_status],
            test_or_order_id: test_res[:test_id]
          ).first
          update_unsync_order(unsync_order)
          Rails.logger.info("=======Successfully updated test in nlims:#{payload[:tracking_number]}=============")
          else
            Rails.logger.error("=============#{response['message']}:#{payload[:tracking_number]}===================")
            raise StandardError, "Failed to create order in nlims: #{response['message']}"
          end
        rescue StandardError => e
          Rails.logger.error("=======#{e.message}:#{payload[:tracking_number]}=============")
          next
        end
      end
    end

    def self.test_payload(test_record)
      client = test_record.order&.encounter&.client&.person
      test_results = TestResult.where(test_id: test_record.id)
                               .where.not(value: '').where.not(value: nil)
      status_trail = TestStatus.where(test_id: test_record.id).map do |st|
        {
          status: st&.status&.name&.gsub('-', '_'),
          timestamp: st&.created_date,
          updated_by: {
            first_name: st.user&.person&.first_name,
            last_name: st.user&.person&.last_name,
            id: st.user&.id,
            phone_number: nil
          }
        }
      end
      test_results = test_results.map do |results|
        test_indicator_test_type = TestTypeTestIndicator.find_by(
          test_indicators_id: results&.test_indicator_id,
          test_types_id: test_record.test_type_id
        )
        {
          measure: {
            name: results&.test_indicator&.name,
            nlims_code: results&.test_indicator&.nlims_code,
            preferred_name: results&.test_indicator&.preferred_name,
            measure_type: test_indicator_test_type&.test_indicator_type
          },
          result: {
            value: results&.value,
            unit: test_indicator_test_type&.unit,
            result_date: results&.created_date,
            platform: results&.machine_name,
            platformserial: ''
          }
        }
      end
      {
        tracking_number: test_record.order&.tracking_number,
        arv_number: client.try(:arv_number),
        test_status: test_record.status&.gsub('-', '_'),
        time_updated: test_record&.updated_date,
        test_type: {
          name: test_record&.test_type&.name,
          nlims_code: test_record&.test_type&.nlims_code
        },
        test_results: test_results,
        status_trail: status_trail
      }
    end

    def self.order_payload(order)
      person_creator = Person.find_by(id: User.find_by(id: order&.creator)&.person_id)
      client = order&.encounter&.client
      {
        order: {
          tracking_number: order&.tracking_number,
          sample_type: order&.tests&.first&.specimen,
          sample_status: { name: Status.find_by(id: order&.status_id)&.name&.gsub('-', '_') || 'specimen_collected' },
          order_location: order&.encounter&.facility_section&.name || 'OPD',
          date_created: order&.created_date,
          priority: order&.priority&.name || 'Routine',
          reason_for_test: order&.priority&.name || 'Routine',
          drawn_by: {
            id: person_creator&.id,
            name: person_creator&.fullname,
            phone_number: ''
          },
          target_lab: GlobalService.current_location.name,
          sending_facility: GlobalService.current_location.name,
          district: GlobalService.current_location.district,
          requested_by: order&.requested_by,
          art_start_date: client.try(:art_start_date),
          arv_number: ClientIdentifier.find_by(
            client_identifier_type_id: ClientIdentifierType.find_by(name: 'art_number')&.id,
            client_id: client.id
          )&.value,
          art_regimen: client.try(:art_regimen),
          client_history: order&.encounter&.client_history,
          lab_location: LabLocation.find_by(id: order&.tests&.first&.lab_location_id)&.name,
          source_system: 'IBLIS',
          status_trail: OrderStatus.where(order_id: order.id).map do |trail|
            person_creator = Person.find_by(id: User.find_by(id: trail&.creator)&.person_id)
            {
              status: trail&.status&.name,
              timestamp: trail&.created_date,
              update_by: {
                first_name: person_creator&.first_name,
                last_name: person_creator&.last_name,
                phone_number: nil,
                id: person_creator&.id
              }
            }
          end
        },
        tests: order&.tests&.map do |t|
          test_payload(t)
        end,
        patient: {
          national_patient_id: ClientIdentifier.find_by(
            client_identifier_type_id: ClientIdentifierType.find_by(name: 'npid')&.id,
            client_id: client.id
          )&.value,
          first_name: client&.person&.first_name&.blank? ? client&.person&.last_name : client&.person&.first_name,
          last_name: client&.person&.last_name&.blank? ? client&.person&.first_name : client&.person&.last_name,
          date_of_birth: client&.person&.date_of_birth,
          gender: client&.person&.sex
        }
      }
    end

    def self.update_unsync_order(unsync_order)
      unsync_order&.update!(sync_status: 1)
    end

    def self.id_condition(id)
      id.present? ? " AND uo.id = #{id}" : ''
    end

    def self.nlims_token
      return @nlims_cache if @nlims_cache[:token].present? && @nlims_cache[:expires_at] > Time.now

      config_data = YAML.load_file("#{Rails.root}/config/application.yml")
      nlims_config = config_data['nlims_service']
      Rails.logger.error('=========nlims_service configuration not found=========') if nlims_config.nil?
      @nlims_service = Nlims::RemoteService.new(
        base_url: "#{nlims_config['base_url']}:#{nlims_config['port']}",
        token: '',
        username: nlims_config['username'],
        password: nlims_config['password'],
        enable_real_time_sync: nlims_config['enable_real_time_sync']
      )
      ping = @nlims_service.ping_nlims
      if ping
        auth = @nlims_service.authenticate
        Rails.logger.error('=========Unable to authenticate to nlims service==========') unless auth
        @nlims_cache[:ping] = ping
        @nlims_cache[:token] = @nlims_service.token
        @nlims_cache[:base_url] = @nlims_service.base_url
        @nlims_cache[:enable_real_time_sync] = @nlims_service.enable_real_time_sync
        @nlims_cache[:expires_at] = Time.now + 10.hours
      else
        Rails.logger.error('=======Nlims service is not available=============')
        @nlims_cache[:token] = nil
      end
      @nlims_cache
    end

    def self.get_test_catalog(version)
      nlims = nlims_token
      response = RestClient::Request.execute(
        method: :get,
        url: "#{nlims[:base_url]}/api/v1/retrieve_test_catalog?version=#{version}",
        headers: { content_type: :json, accept: :json, 'token': nlims[:token].to_s }
      )
      if response.code == 200
        JSON.parse(response.body, symbolize_names: true)
      else
        {}
      end
    end

    def self.check_new_test_catalog_version(version)
      nlims = nlims_token
      response = RestClient::Request.execute(
        method: :get,
        url: "#{nlims[:base_url]}/api/v1/check_new_test_catalog_version_available?version=#{version}",
        headers: { content_type: :json, accept: :json, 'token': nlims[:token].to_s }
      )
      JSON.parse(response.body, symbolize_names: true)
    end

    def self.get_test_catalog_versions
      nlims = nlims_token
      response = RestClient::Request.execute(
        method: :get,
        url: "#{nlims[:base_url]}/api/v1/retrieve_test_catalog_versions",
        headers: { content_type: :json, accept: :json, 'token': nlims[:token].to_s }
      )
      JSON.parse(response.body, symbolize_names: true)
    end
  end
end
