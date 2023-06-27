module LabConfig
  class AnalyticsService
    def test_catalog_summary
      count = {}
      count['facilities'] = Facility.all.count
      count['visit_types'] = EncounterType.all.count
      count['instruments'] = Instrument.all.count
      count['wards'] = FacilitySection.all.count
      count
    end
  end
end
