module TestCatalog
  module TestTypeService
    class << self
      def create(params)
        begin
          ActiveRecord::Base.transaction do 
            testtype = TestType.new(name: params[:name], short_name: params[:short_name], department_id: params[:department_id],
              expected_turn_around_time: params[:expected_turn_around_time], retired: 0, creator: User.current.id,
              created_date: Time.now, updated_date: Time.now)
            if testtype.save
              TestCatalog::TestTypeUtil.create_specimen_test_type_mapping(testtype.id, params[:specimens])
              TestCatalog::TestTypeUtil.create_indicator(testtype.id, params[:indicators])
            end
          end
          return {status: true, error: false, msg: "successful"}
        rescue => e
          return {status: false, error: e.message, msg: "unsuccessful"}
        end
      end
    end
  end
end