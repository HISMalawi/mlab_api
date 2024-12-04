# frozen_string_literal: true

module OerrService
  class << self
    # Segments: "Jane^Doe~DF5U00~0~487720800~44~chaliram~mass~3~1733123041~32^31~R"
    def order_dto(segments, lab_location)
      segments = segments.split('~')
      specimen = Specimen.find_by(id: segments[7])&.id
      {
        client: { uuid: segments[1] },
        client_identifiers: {
          current_village: '',
          current_district: '',
          current_traditional_authority: '',
          physical_address: '',
          npid: segments[1]
        },
        person: {
          first_name: segments[0].split('^').first,
          middle_name: '',
          last_name: segments[0].split('^').last,
          sex: segments[2].to_i.zero? ? 'F' : 'M',
          date_of_birth: Time.at(segments[3].to_i).to_date,
          birth_date_estimated: false
        },
        encounter: {
          sending_facility: Facility.find_by(id: GlobalService.current_location.id)&.id,
          encounter_type: EncounterType.find_by(name: 'In Patient')&.id,
          facility_section: FacilitySection.find_by(id: segments[4])&.id,
          client_history: segments[6]
        },
        lab_location:,
        order: {
          priority: Priority.find_by(name: { 'S' => 'STAT', 'R' => 'ROUTINE' }['R'])&.id || Priority.first&.id,
          requested_by: sample_collector(segments[5]),
          collected_by: sample_collector(segments[5]),
          sample_collected_time: Time.at(segments[8].to_i),
          tracking_number: ''
        },
        tests: segments[9].split('^').collect do |test_type_id|
          { specimen:, test_type: TestType.find(test_type_id).name }
        end
      }
    end

    def sample_collector(segment)
      return '' if segment.blank?

      clinician = CGI.unescapeHTML(segment.strip).split(/\s+/)
      c_last_name = clinician.last
      begin
        (clinician - [c_last_name]).join(' ')
      rescue StandardError
        ''
      end
      CGI.unescapeHTML(segment.strip)
    end

    def create_oerr_sync_trail(order, params)
      Test.where(order_id: order.id).each do |test|
        OerrSyncTrail.create(
          order_id: order.id,
          test_id: test.id,
          npid: params[:client][:uuid],
          facility_section_id: params[:encounter][:facility_section],
          requested_by: params[:order][:requested_by],
          sample_collected_time: params[:order][:sample_collected_time],
          synced: false,
          synced_at: nil
        )
      end
    end

    def oerr_sync_trail_update(oerr_sync_trail, doc_id = '')
      oerr_sync_trail.update(synced: true, synced_at: Time.now, doc_id:)
      OerrSyncTrail.where(order_id: oerr_sync_trail.order_id).update_all(doc_id:)
    end

    def create_oerr_sync_trail_on_update(oerr_sync_trail)
      OerrSyncTrail.create(
        order_id: oerr_sync_trail.order_id,
        test_id: oerr_sync_trail.test_id,
        npid: oerr_sync_trail.npid,
        facility_section_id: oerr_sync_trail.facility_section_id,
        requested_by: oerr_sync_trail.requested_by,
        sample_collected_time: oerr_sync_trail.sample_collected_time,
        doc_id: oerr_sync_trail.doc_id,
        synced: false,
        synced_at: nil
      )
    end

    def to_oerr_dto(oerr_sync_trail)
      test_obj = Tests::TestService.new.find(oerr_sync_trail.test_id)
      test_obj[:oerr_identifiers] = oerr_sync_trail
      test_obj
    end

    def push_to_oerr(oerr_sync_trail)
      oerr_config = OerrService.oerr_configs
      url = "#{oerr_config[:base_url]}/oerr_update/"
      response = RestClient::Request.execute(
                method: :post,
                url:,
                payload: to_oerr_dto(oerr_sync_trail).to_json,
                headers: { content_type: :json, accept: :json },
                user: oerr_config[:username],
                password: oerr_config[:password]
              )
      if response.code == 200
        data = JSON.parse(response.body)
        Rails.logger.info "Pushed to oerr #{data}"
        puts "Pushed to oerr #{data}"
        Rails.logger.info "Pushed to oerr #{data}"
        oerr_sync_trail_update(oerr_sync_trail, data['doc_id']) if data['doc_id']
      else
        Rails.logger.error "Error pushing to oerr #{response.body}"
        raise "Error pushing to oerr #{response.body}"
      end
    end

    def oerr_configs
      config_data = YAML.load_file("#{Rails.root}/config/application.yml")
      oerr_config = config_data['oerr_service']
      raise 'OERR configuration not found' if oerr_config.nil?

      {
        base_url: oerr_config['base_url'],
        username: oerr_config['username'],
        password: oerr_config['password']
      }
    end
  end
end
