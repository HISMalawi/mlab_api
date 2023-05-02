# frozen_string_literal: true

# Model for diseases
class Disease < VoidableRecord 
  has_many :surveillances, class_name: 'Surveillance', foreign_key: 'diseases_id', primary_key: :id

  validates :name, uniqueness: true, presence: true
end