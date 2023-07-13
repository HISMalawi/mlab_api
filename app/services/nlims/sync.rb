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
                  WHERE uo.data_level = 'order' AND uo.data_not_synced ='new order' AND uo.sync_status = 0"
      )
      facility_details = GlobalService.current_location
      orders.each do |order|
        tests = Test.where(order_id: order[:id])
        priority = Priority.find(order[:priority_id]).name
        encounter = Encounter.find(order[:encounter_id])
        client = encounter.client.person
        payload = {
          tracking_number: order[:tracking_number] + '-12',
          date_sample_drawn: order[:sample_collected_time].blank? ? order[:created_date] : order[:sample_collected_time],
          date_received: order[:created_date],
          health_facility_name: facility_details[:name],
          # district: facility_details[:district],
          target_lab: facility_details[:name],
          requesting_clinician: order[:requested_by],
          return_json: 'true',
          sample_type: tests.first.specimen_type,
          tests: tests.joins(:test_type).pluck('test_types.name'),
          sample_status: OrderStatus.where(order_id: order[:id]).order(created_date: :asc).first.status.name.gsub!('-', '_'),
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
          payload:
        )
        response = JSON.parse(response.body)
        if response['error']
          Rails.logger.error(response['message'])
        elsif response['erorr'] == false && response['message'] == 'order created successfuly'
          unsync_order = UnsyncOrder.where(sync_status: 0, data_not_synced: 'new order',
                                           test_or_order_id: order[:id]).first
          unsync_order.update(sync_status: 1)
        end
      end
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

    def update_test
      # for test statuses except verified
      data = {
        tracking_number: 'XKCH236E540',
        test_status: 'completed',
        test_name: 'FBC',
        result_date: '',
        who_updated: {
          first_name: '',
          last_name: '',
          id: ''
        },
        test: {}
      }

      # for verified statuses
      {
        tracking_number: 'XKCH236E540',
        test_status: 'verified',
        test_name: 'FBC',
        result_date: '',
        who_updated: {
          first_name: '',
          last_name: '',
          id: ''
        },
        results: {
          RBC: '4.87',
          HGB: '13.5',
          HCT: '38.1',
          MCV: '78.2',
          MCH: '27.7',
          MCHC: '35.4',
          PLT: '294',
          "RDW-SD": '37.6',
          "RDW-CV": '13.4',
          PDW: '11.8',
          MPV: '10.4 +',
          PCT: '0.31',
          "NEUT%": '66.6 *',
          "LYMPH%": '23.9 *',
          "MONO%": '9 *',
          "EO%": '0.2 *',
          "BASO%": '0.3 *',
          "NEUT#": '6.98 *',
          "LYMPH#": '2.5 *',
          "MONO#": '0.94 *',
          "EO#": '0.02 *',
          "BASO#": '0.03 *',
          WBC: '10.47 *',
          "P-LCC": '',
          "P-LCR": '27.6',
          "RET %": '',
          "RET#": '',
          "NRBC%": '0',
          "NRBC#": '0'
        },
        test: {}
      }
    end
  end
end

# order = {
#   tracking_number: "XMJD2200011009",
#   district: "Lilongwe",
#   health_facility_name: "Kamuzu Central Hospital Laboratory",
#   sample_type: "Swabs",
#   date_sample_drawn: "2022-08-10 12:45:48",
#   sample_status: "specimen_not_collected",
#   sample_priority: "Routine",
#   art_start_date: "",
#   date_received: "2022-08-10 12:45:48",
#   requesting_clinician: "",
#   return_json: "true",
#   target_lab: "Kamuzu Central Hospital Laboratory",
#   tests: ["HPV"],
#   who_order_test_last_name: "",
#   who_order_test_first_name: "",
#   who_order_test_phone_number: "",
#   who_order_test_id: nil,
#   order_location: "MCH OPD",
#   first_name: "MERCY",
#   last_name: "NAKUNTHO",
#   middle_name: "",
#   reason_for_test: "Routine",
#   date_of_birth: "1972-07-01",
#   gender: 1,
#   patient_residence: "",
#   patient_location: "",
#   patient_town: "",
#   patient_district: "",
#   national_patient_id: "",
#   phone_number: ""
# }
