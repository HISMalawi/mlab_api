# frozen_string_literal: true

module Reports
  # Drilldown reports module
  class DrilldownService
    def initialize(drilldown_type: nil)
      @drilldown_type = drilldown_type
    end

    def drilldown(drilldown_identifier)
      drilldowns = default_drilldown(drilldown_identifier) if @drilldown_type.nil?
      DrilldownIdentifier.delete(drilldown_identifier)
      drilldowns
    end

    private

    def map_drilldowns(drilldowns)
      drilldowns.map do |drilldown|
        {
          id: drilldown['id'],
          first_name: drilldown['first_name'],
          last_name: drilldown['last_name'],
          sex: drilldown['sex'],
          date_of_birth: drilldown['date_of_birth'],
          accession_number: drilldown['accession_number'],
          test_type: drilldown['test_type'],
          specimen: Specimen.find_by(id: drilldown['specimen_id']).try(:name),
          department: drilldown['department'],
          updated_date: drilldown['updated_date'],
          sample_collected_time: drilldown['sample_collected_time'],
          test_indicators: test_indicator_seriliazer_service(drilldown)
        }
      end
    end

    def exec_query(query)
      Report.find_by_sql(query)
    end

    def test_indicator_seriliazer_service(drilldown)
      serializer = Serializers::TestIndicatorSerializer.new
      serializer.serialize(drilldown['id'], drilldown['test_type_id'], drilldown['sex'], drilldown['date_of_birth'])
    end

    def default_drilldown(drilldown_identifier)
      records = Report.find_by_sql(test_service.query(associated_ids(drilldown_identifier)))
      test_service.serialize_tests(records, is_test_list: false, is_client_report: true)
    end

    def associated_ids(drilldown_identifier)
      ids = DrilldownIdentifier.find(drilldown_identifier).data['associated_ids']
      ids.empty? ? "('unknown')" : "(#{ids})"
    end

    def test_service
      Tests::TestService.new
    end
  end
end
