module Api
  module V1
    class OrganismsController < ApplicationController
      before_action :set_organism, only: [:show, :update, :destroy]
    
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
    
    end
    
  end
end