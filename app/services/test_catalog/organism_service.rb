module TestCatalog
  module OrganismService
    class << self

      def create_organism(organism_params, params)
        ActiveRecord::Base.transaction do
          @organism = Organism.create!(organism_params)
          params[:drugs].each do |drug|
            DrugOrganismMapping.create!(drug_id: drug, organism_id: @organism.id)
          end
        end
        @organism
      end

      def show_organism(organism)
        drugs = DrugOrganismMapping.joins(:drug).where(organism_id: organism.id).select('drugs.id, drugs.name, drugs.short_name')
        serialize_organism_drug(organism, drugs)
      end

      def get_organisms_based_test_type(test_type)
        test_type = TestType.find_by_name(test_type)
        raise ActiveRecord::RecordNotFound if test_type.nil?
        TestTypeOrganismMapping.joins(:organism).where(test_type_id: test_type.id).select('organisms.id, organisms.name')
      end

      def update_organism(organism, organism_params, params)
        ActiveRecord::Base.transaction do 
          organism.update!(organism_params)
          DrugOrganismMapping.where(organism_id: organism.id).where.not(drug_id: params[:drugs]).each do |drug_organism|
            drug_organism.void("Removed from #{organism.name} organism")
          end
          params[:drugs].each do |drug_id|
            DrugOrganismMapping.find_or_create_by!(drug_id: drug_id, organism_id: organism.id)
          end
        end
      end

      def void_organism(organism, reason)
        unless reason
          raise ActionController::ParameterMissing, 'for retired_reason'
        end
        organism.void(reason)
        drug_organisms = DrugOrganismMapping.where(organism_id: organism.id)
        drug_organisms.each do |drug_organism|
          drug_organism.void(reason)
        end
      end

      def serialize_organism_drug(organism, drugs)
        {
          id: organism.id,
          name: organism.name,
          description: organism.description,
          drugs: drugs
        }
      end

    end
  end
end