class TestType < RetirableRecord
  belongs_to :department
  has_many :instrument_test_type_mapping

  validates :name, uniqueness: true, presence: true
  has_many :test_indicators

  def self.search(search_term)
    where("name LIKE '%#{search_term}%' OR short_name LIKE '%#{search_term}%'")
  end
end
