class DrugSusceptibility < VoidableRecord
  belongs_to :test
  belongs_to :organism
  belongs_to :drug
end
