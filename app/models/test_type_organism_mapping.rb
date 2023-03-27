class TestTypeOrganismMapping < ApplicationRecord
  belongs_to :test_type
  belongs_to :organism
end
