class DrugOrganismMapping < ApplicationRecord
  belongs_to :drug
  belongs_to :organism
end
