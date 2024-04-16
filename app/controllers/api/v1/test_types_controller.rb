module Api
  module V1
    class TestTypesController < ApplicationController
      before_action :set_test_type, only: %i[show update destroy]
      before_action :check_specimen_indicator_params, only: %i[create update]

      def index
        @test_types = TestType.active_without_paediatric_cancer.all.order(:name)
        meta = {}
        if params[:search].blank?
          unless params[:page].blank?
            @test_types = @test_types.page(params[:page]).per(params[:per_page])
            meta = PaginationService.pagination_metadata(@test_types)
          end
        else
          @test_types = TestType.active_without_paediatric_cancer.search(params[:search]).order(:name).page.per(params[:per_page])
          meta = PaginationService.pagination_metadata(@test_types)
        end
        render json: { test_types: @test_types, meta: }
      end

      def test_indicator_types
        render json: TestCatalog::TestTypes::TestIndicatorType.show_test_indicator_types
      end

      def department_test_types
        department_id = params.require(:department_id)
        render json: TestType.active_without_paediatric_cancer.where(department_id:)
      end

      def show
        render json: TestCatalog::TestTypes::ShowService.show_test_type(@test_type)
      end

      def create
        test_type = TestCatalog::TestTypes::CreateService.create_test_type(test_type_params, params)
        render json: TestCatalog::TestTypes::ShowService.show_test_type(test_type), status: :created
      end

      def update
        TestCatalog::TestTypes::UpdateService.update_test_type(@test_type, test_type_params, params)
        render json: @test_type
      end

      def destroy
        TestCatalog::TestTypes::DeleteService.void_test_type(@test_type, params[:retired_reason])
        render json: { message: MessageService::RECORD_DELETED }
      end

      private

      def set_test_type
        @test_type = TestType.find(params[:id])
      end

      def test_type_params
        params.require(:test_type).permit(:name, :short_name, :department_id, :print_device)
      end

      def check_specimen_indicator_params
        unless params.has_key?('specimens') && params[:specimens].is_a?(Array)
          raise ActionController::ParameterMissing, MessageService::VALUE_NOT_ARRAY << ' for specimens'
        end
        return if params.has_key?('indicators') && params[:indicators].is_a?(Array)

        raise ActionController::ParameterMissing, MessageService::VALUE_NOT_ARRAY << ' for indicators'
      end
    end
  end
end
