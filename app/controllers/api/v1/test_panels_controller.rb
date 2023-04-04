module Api
  module V1
    class TestPanelsController < ApplicationController
      before_action :set_test_panel, only: [:show, :update, :destroy]
      before_action :check_test_type_params, only: [:create, :update]
    
      def index
        @test_panels = TestPanel.all
        render json: @test_panels
      end
      
      def show
        render json: TestCatalog::TestPanelService.show_panel(@test_panel)
      end
    
      def create
        @test_panel = TestCatalog::TestPanelService.create_panel(test_panel_params, params)
        render json: @test_panel, status: :created
      end
    
      def update
        @test_panel = TestCatalog::TestPanelService.update_panel(@test_panel, test_panel_params, params[:test_types])
        render json: @test_panel
      end
    
      def destroy
       @test_panel = TestCatalog::TestPanelService.void_panel(@test_panel, params[:retired_reason])
       render json: {message: MessageService::RECORD_DELETED}
      end
    
      private
    
      def set_test_panel
        @test_panel = TestPanel.find(params[:id])
      end
    
      def test_panel_params
        params.require(:test_panel).permit(:name, :description, :short_name)
      end

      def check_test_type_params
        unless params.has_key?('test_types') && params[:test_types].is_a?(Array)
          raise ActionController::ParameterMissing, MessageService::VALUE_NOT_ARRAY << " for test_types"
        end
      end

    end
    
  end
end