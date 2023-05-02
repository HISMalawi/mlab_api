class Status < RetirableRecord
  validates :name, uniqueness: true, presence: true

  def as_json(options = {})
    super(options.merge({only: %i[id name]}))
  end
end
