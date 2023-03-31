module Api
  module V1
    class TestTypesController < ApplicationController
      before_action :set_test_type, only: [:show, :update, :destroy]
    
      def index
        @test_types = TestType.all
        render json: @test_types
      end
      
      def test_indicator_types
        render json: TestCatalog::TestType::TestIndicatorType.show_test_indicator_types
      end 
    
      def show
        render json: TestCatalog::TestType::ShowService.show_test_type(@test_type)
      end
    
      def create
        perform_create = TestCatalog::TestTypeService.create(test_type_params)
        if perform_create[:status]
          render json: perform_create, status: :created
        else
          render json: perform_create, status: :unprocessable_entity
        end
      end
    
      def update
        if @test_type.nil?
          render json: {error: true, message: MessageService::RECORD_NOT_FOUND}, status: :ok
        else
          response = TestCatalog::TestTypeService.update(@test_type, test_type_params)
          if response[:status]
            render json: {error: false, message: MessageService::RECORD_UPDATED, test_type: TestCatalog::TestTypeService.show(@test_type)}, status: :ok
          else
            render json: {error: false, message: response[:error]}, status: :unprocessable_entity
          end
        end
      end
    
      def destroy
        TestCatalog::TestType::DeleteService.void_test_type(@test_type, params[:retired_reason])
        render json: @test_type
      end
    
      private
    
      def set_test_type
        @test_type = TestType.find(params[:id])
      end
    
      def test_type_params
        params.require(:test_type).permit(:name, :short_name, :department_id, :expected_turn_around_time)
      end

      # TO DO: ADD PARAMETERS MISSING CHECK FOR INDICATOR PARAMS, SPECIMEN PARAMS

    end
    
  end
end