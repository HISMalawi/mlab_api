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
        @response = nil
        params[:drugs].each do |drug|
          @response = DrugSusceptibility.create!(
            test_id: params.require(:test_id),
            organism_id: params.require(:organism_id),
            drug_id: drug[:drug_id],
            zone: drug[:zone],
            interpretation: drug[:interpretation]
          )
        end
        @response 
      end

    end
  end
end