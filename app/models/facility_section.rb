class FacilitySection < RetirableRecord
  validates :name, presence: true, uniqueness: true

  def as_json(options = {})
    super(options.merge({ only: %i[id name] }))
  end
end
