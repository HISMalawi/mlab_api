module Tests
  module CultureSensivityService
    class << self
      def get_culture_obs(culture_ob)
        test_ =  Test.find(culture_ob.test_id).test_type.name
        {
          culture_obs_id: culture_ob.id,
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
    end
  end
end