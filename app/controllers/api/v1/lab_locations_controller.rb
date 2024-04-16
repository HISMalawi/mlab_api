# frozen_string_literal: true

# module API
module Api
  # module API
  module V1
    # Lab location controller
    class LabLocationsController < ApplicationController
      before_action :set_lab_location, only: %i[show update destroy]

      def index
        render json: LabLocation.all
      end

      def show
        render json: @lab_location
      end

      def create
        lab_location = LabLocation.create!(lab_location_params)
        render json: lab_location
      end

      def update
        @lab_location.update!(lab_location_params)
        render json: @lab_location, status: :ok
      end

      def destroy
        render json: @lab_location.void(lab_location_params[:voided_reason])
      end

      private

      def lab_location_params
        params.require(:lab_location).permit(:name, :id, :voided_reason)
      end

      def set_lab_location
        @lab_location = LabLocation.find(params[:id])
      end
    end
  end
end
