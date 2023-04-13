class TestType < RetirableRecord
  belongs_to :department
  validates :name, uniqueness: true, presence: true

  def self.search(search_term)
    where("name LIKE '%#{search_term}%'")
  end
end
