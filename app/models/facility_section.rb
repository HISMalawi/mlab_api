class FacilitySection < RetirableRecord
    def as_json(options={})
        super(options.merge({only: %i[id name]}))
    end
end
