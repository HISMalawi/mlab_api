class DrugSusceptibility < VoidableRecord
  belongs_to :test
  belongs_to :organism
  belongs_to :drug


  def as_json(options = {})
    super(options.merge({only: %i[organism_id test_id drug_id zone interpretation]}))
  end
end
