module OrderService
  class << self
    # TO DO: IMPLEMENT PARAMS VALIDATIONS

    def create_encounter(encounter_params)
      client = encounter_params[:client_id]
      facility = Facility.find_or_create_by!(name: encounter_params[:sending_facility])
      facility_section = FacilitySection.find_or_create_by!(name: encounter_params[:facility_section])
      visit_type = VisitType.find_or_create_by!(name: encounter_params[:visit_type])
      destination = facility
      if visit_type == 'referal'
        destination = Facility.find_or_create_by!(name: encounter_params[:destination_facility])
      end
      Encounter.create!(
        client_id: client_id,
        facility_id: facility.id,
        destination_id: destination.id,
        facility_section_id: facility_section.id,
        start_date: Time.now
      )
    end

    def create_order(encounter_id, order_params)
      accession_number = generate_accession_number
      tracking_number = "X#{accession_number}" if !order_params[:tracking_number].blank?
      Order.create!(
        encounter_id: encounter_id,
        priority: order_params[:priority],
        accession_number: accession_number,
        tracking_number: tracking_number,
        sample_collected_time: order_params[:sample_collected_time],
        requested_by: order_params[:requested_by],
        collected_by: order_params[:collected_by]
      )
    end

    def create_test(order_id, test_params)
      # TO DO: HANDLE TEST PANELS

      Test.create!(
        specimen_id: Specimen.find_by_name(test_params[:specimen_id]).id,
        order_id: order_id,
        test_type_id: TestType.find_by_name(test_params[:test_type]).id
      )
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