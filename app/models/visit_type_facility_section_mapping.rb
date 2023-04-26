class VisitTypeFacilitySectionMapping < RetirableRecord
    belongs_to :visit_type
    belongs_to :facility_section
end
