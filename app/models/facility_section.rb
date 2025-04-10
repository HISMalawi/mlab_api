# frozen_string_literal: true

# Model for facility section
class FacilitySection < RetirableRecord
  has_many :post_crossmatch_processes, dependent: :destroy
  validates :name, presence: true, uniqueness: true

  def as_json(options = {})
    super(options.merge({ only: %i[id name] }))
  end
end
