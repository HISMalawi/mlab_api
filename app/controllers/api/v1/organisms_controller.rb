module Api
  module V1
    class OrganismsController < ApplicationController
      before_action :set_organism, only: [:show, :update, :destroy]
      before_action :check_drug_params, only: [:create, :update]

      def index
        @organisms = Organism.all
        render json: @organisms
      end
      
      def show
        render json: TestCatalog::OrganismService.show_organism(@organism)
      end
    
      def create
        @organism = TestCatalog::OrganismService.create_organism(organism_params, params)
        render json: @organism, status: :created
      end
    
      def update
        TestCatalog::OrganismService.update_organism(@organism, organism_params, params)
        render json: @organism
      end
    
      def destroy
        TestCatalog::OrganismService.void_organism(@organism, params[:retired_reason])
        render json: @organism
      end
    
      private
    
      def set_organism
        @organism = Organism.find(params[:id])
      end
    
      def organism_params
        params.require(:organism).permit(:name, :description)
      end

      def check_drug_params
        unless params.has_key?('drugs') && params[:drugs].is_a?(Array)
          raise ActionController::ParameterMissing, MessageService::VALUE_NOT_ARRAY << " for drugs"
        end
      end
    
    end
    
  end
end