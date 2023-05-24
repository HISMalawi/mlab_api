module Tests
  module CultureSensivityService
    class << self
      def get_culture_obs(culture_ob)
        test_ =  Test.find(culture_ob.test_id).test_type.name
        {
          culture_obs_id: culture_ob.id,
          user: UserManagement::UserService.find_user(culture_ob.creator),
          test_type: test_,
          description: culture_ob.description,
          observation_date: culture_ob.observation_datetime
        }
      end

      def culture_ob_all(culture_obs)
        c_obj = []
        culture_obs.each do |culture_ob|
          c_obj << get_culture_obs(culture_ob)
        end
        c_obj
      end

      def drug_susceptibility_test_results(params)
        response = params[:drugs].collect do |drug|
          d = DrugSusceptibility.find_or_create_by(
            test_id: params.require(:test_id),
            organism_id: params.require(:organism_id),
            drug_id: drug[:drug_id],
          )
          d.update!(zone: drug[:zone], interpretation: drug[:interpretation])
          d
        end
        response
      end

      def get_drug_susceptibility_test_results(test_id)
        results = DrugSusceptibility.where(test_id:).as_json
        data = results.collect do |organism|
          {
            test_id: organism["test_id"],
            organism_id: organism["organism_id"],
            name: Organism.find(organism["organism_id"]).name,
            drugs: results.select { |r| r["organism_id"] == organism["organism_id"] }.map do |drug|
              drug["name"] = Drug.find(drug["drug_id"]).name
              drug
            end
          }
        end
        data.uniq { |r| r[:organism_id] }
      end

      def culture_observation(test_id)
        culture_obs = CultureObservation.where(test_id:)
        culture_ob_all(culture_obs)
      end

      def delete_drug_susceptibility_test_results(params)
        drug_suscep_test_results = DrugSusceptibility.where(
          test_id: params.require(:test_id),
          organism_id: params.require(:organism_id)
        )
        drug_suscep_test_results.each do |drug_suscep_test_result|
          drug_suscep_test_result.void('Deleted the test susceptibility results')
        end
      end

      def serialiaze_drug_suscep_test_results(results, culture_obs)
        results_ = []
        results.each do |result|
          results_ << {
            test_id: result.test_id,
            organism_id: result.organism_id,
            organism_name: result.organism.name,
            drug_id: result.drug_id,
            drug_name: result.drug.name,
            zone: result.zone,
            interpretation: result.interpretation
          }
        end
        {
          culture_observations: culture_ob_all(culture_obs),
          drug_suscep_test_results: results_
        }
      end

    end
  end
end
