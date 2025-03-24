# frozen_string_literal: true

# Model for DrugOrganismMapping table
class DrugOrganismMapping < RetirableRecord
  belongs_to :drug
  belongs_to :organism
end
