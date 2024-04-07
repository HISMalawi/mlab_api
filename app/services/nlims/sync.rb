Rails.logger = Logger.new(STDOUT)
module Nlims
  module Sync
    def self.create_order
      nlims  = nlims_token
      return if nlims[:token].blank?

      orders =  Order.find_by_sql(
        "SELECT o.id, o.encounter_id, o.tracking_number, o.sample_collected_time,
                    o.collected_by, o.requested_by , o.created_date , o.updated_date, o.priority_id
                  FROM orders o
                  INNER JOIN unsync_orders uo ON
                    uo.test_or_order_id = o.id
                  WHERE uo.data_level = 'order' AND uo.data_not_synced ='new order' AND uo.sync_status = 0
                  ORDER BY uo.id DESC LIMIT 100"
      )
      facility_details = GlobalService.current_location
      orders.each do |order|
        Rails.logger.info('=======Creating orders in nlims=============')
        tests = Test.where(order_id: order[:id])
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
          sample_type: tests.first.specimen_type,
          tests: tests.joins(:test_type).pluck('test_types.name'),
          sample_status: OrderStatus.where(order_id: order[:id]).order(created_date: :asc).first.status.name.gsub('-',
                                                                                                                  '_'),
          sample_priority: priority,
          reason_for_test: priority,
          order_location: encounter.facility_section.name,
          who_order_test_id: nil,
          who_order_test_last_name: '',
          who_order_test_first_name: '',
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

    def self.update_order
      nlims = nlims_token
      return if nlims[:token].blank?

      orders = Order.find_by_sql("
        SELECT o.tracking_number , cos.name AS status, cos.creator AS updater, uo.test_or_order_id AS id
        FROM unsync_orders uo
        INNER JOIN current_order_status cos ON cos.order_id = uo.test_or_order_id
        INNER JOIN orders o ON uo.test_or_order_id = o.id
        WHERE uo.data_level = 'order' AND (uo.data_not_synced = 'specimen-accepted' OR uo.data_not_synced = 'specimen-rejected')
          AND uo.sync_status = 0 LIMIT 100
        ")
      orders.each do |order|
        Rails.logger.info('=======Updating orders in nlims=============')
        first_name = order[:updater].split(' ')[0]
        last_name = order[:updater].split(' ')[1]
        payload = {
          tracking_number: order[:tracking_number],
          status: order.status.gsub('-', '_'),
          who_updated: {
            first_name:,
            last_name:,
            id: nil
          }
        }
        response = RestClient::Request.execute(
          method: :post,
          url: "#{nlims[:base_url]}/api/v1/update_order/",
          headers: { content_type: :json, accept: :json, 'token': "#{nlims[:token]}" },
          payload: payload.to_json
        )
        response = JSON.parse(response.body)
        if response['error'] == false && response['message'] == 'order updated successfuly'
          unsync_order = UnsyncOrder.where(sync_status: 0, data_not_synced: order[:status],
                                           test_or_order_id: order[:id]).first
          update_unsync_order(unsync_order)
          Rails.logger.info("=======Successfully updated orders in nlims: #{payload[:tracking_number]}=============")
        else
          Rails.logger.info("=======#{response['message']}:#{payload[:tracking_number]}=============")
        end
      end
    end

    def self.update_test
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
            uo.data_level = 'test' AND uo.sync_status = 0 ORDER BY uo.id DESC LIMIT 100
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
        if test_res[:test_status] == 'result' || test_res[:test_status] == 'verified'
          test_results = TestResult.joins(:test_indicator).where(test_id: test_res[:test_id])
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

    def self.update_unsync_order(unsync_order)
      unsync_order&.update!(sync_status: 1)
    end

    def self.nlims_token
      token = ''
      base_url = ''
      config_data = YAML.load_file("#{Rails.root}/config/application.yml")
      nlims_config = config_data['nlims_service']
      Rails.logger.error('=========nlims_service configuration not found=========') if nlims_config.nil?
      @nlims_service = Nlims::RemoteService.new(
        base_url: "#{nlims_config['base_url']}:#{nlims_config['port']}",
        token: '',
        username: nlims_config['username'],
        password: nlims_config['password']
      )
      if @nlims_service.ping_nlims
        auth = @nlims_service.authenticate
        unless auth
          Rails.logger.error('=========Unable to authenticate to nlims service: Nlims service not available==========')
        end
        token = @nlims_service.token
        base_url = @nlims_service.base_url
      else
        Rails.logger.error('=======Nlims service is not available=============')
      end
      {
        token:,
        base_url:
      }
    end
  end
end
