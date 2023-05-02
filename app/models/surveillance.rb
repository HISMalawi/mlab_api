# frozen_string_literal: true

# Maps diseases to their test types
class Surveillance < VoidableRecord 
  belongs_to :disease, class_name: 'Disease', foreign_key: :diseases_id, primary_key: :id
  belongs_to :test_type, class_name: 'TestType', foreign_key: :test_types_id, primary_key: :id
  belongs_to :user, class_name: 'User', foreign_key: :creator, primary_key: :id

  has_one :person, through: :user

  validates :diseases_id, presence: true
  validates :test_types_id, presence: true

  def as_json(options = {})
    super(options.merge(
      only: %i[id diseases_id test_types_id],
      include: {
        disease: { only: %i[id name]},
        test_type: {only: %i[id name short_name]},
        person: {only: %i[id first_name middle_name last_name sex date_of_birth]},
        user: {only: %i[id]}
      }
    ))
  end
end