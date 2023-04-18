class DrugOrganismMapping < RetirableRecord
  belongs_to :drug
  belongs_to :organism
end
