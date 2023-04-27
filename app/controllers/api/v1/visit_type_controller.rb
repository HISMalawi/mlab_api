class Api::V1::VisitTypeController < ApplicationController
    before_action :set_visit_type, only: [:show, :update, :destroy]

    def index
        @visit_type = VisitType.all
        render json: @visit_type
    end

    def show 
        render json: @visit_type
    end
    
    def create
     
      @visit_type = VisitType.new(visit_type_params)

      if @visit_type.save
        render json: @visit_type, status: :created, location: [:api, :v1, @visit_type]
      else
        render json: @visit_type.errors, status: :unprocessable_entity
      end
    end

    def update
      if @visit_type.update(name: visit_type_params)
        render json: @visit_type
      else
        render json: @visit_type.errors, status: :unprocessable_entity
      end
    end

    def destroy
      @visit_type.destroy
    end

    private
    
    def set_visit_type
      @visit_type = VisitType.find(params[:id])
    end

    def visit_type_params
      params.require(:name)
    end
end
