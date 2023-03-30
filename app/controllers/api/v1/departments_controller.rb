module Api
  module V1
    class DepartmentsController < ApplicationController
      before_action :set_department, only: [:show, :update, :destroy]
      skip_before_action :authorize_request, only: [:index]
    
      def index
        @departments = Department.all
        render json: @departments
      end
      
      def show
        render json: @department
      end
    
      def create
        @department = Department.create!(department_params)
        render json: @department, status: :created
      end
    
      def update
        @department.update!(department_params)
        render json: @department
      end
    
      def destroy
        @department.void(params[:retired_reason])
        render json: @department
      end
    
      private
    
      def set_department
        @department = Department.find(params[:id])
      end
    
      def department_params
        params.require(:department).permit(:name)
      end
    end
  end
end



