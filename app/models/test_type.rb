class TestType < RetirableRecord
  belongs_to :department
  has_many :instrument_test_type_mapping
  has_many :specimen_test_type_mappings
  has_many :specimens, through: :specimen_test_type_mappings

  validates :name, uniqueness: true, presence: true
  has_one :expected_tats, required: false

  def as_json(options = {})
    methods = %i[expected_turn_around_time]
    super(options.merge(methods: methods))
  end

  def expected_turn_around_time
    ExpectedTat.where(test_type_id: id).first
  end

  def self.search(search_term)
    where("name LIKE '%#{search_term}%' OR short_name LIKE '%#{search_term}%'")
  end
end
