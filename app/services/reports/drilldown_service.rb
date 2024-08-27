# frozen_string_literal: true

module Reports
  # Drilldown reports module
  class DrilldownService
    def initialize(drilldown_type: nil, page: 1, limit: 25)
      @drilldown_type = drilldown_type
      @page = page
      @limit = limit
    end

    def drilldown(drilldown_identifier)
      drilldowns = default_drilldown(drilldown_identifier) if @drilldown_type.nil?
      drilldowns
    end

    private

    def map_drilldowns(drilldowns)
      drilldowns.map do |drilldown|
        test_dto = Serializers::TestSerializer.serialize(drilldown)
        test_dto[:results] = Serializers::TestResultSerializer.serialize(test_dto[:id])
        test_dto
      end
    end

    def default_drilldown(drilldown_identifier)
      records = Report.find_by_sql(Sql::Test.query(associated_ids(drilldown_identifier)))
      paginated_records = PaginationService.paginate_array(records, page: @page, limit: @limit)
      {
        data: map_drilldowns(paginated_records),
        meta: PaginationService.pagination_metadata(paginated_records)
      }
    end

    def associated_ids(drilldown_identifier)
      ids = DrilldownIdentifier.find(drilldown_identifier).data['associated_ids']
      ids.empty? ? "('unknown')" : "(#{ids})"
    end
  end
end
