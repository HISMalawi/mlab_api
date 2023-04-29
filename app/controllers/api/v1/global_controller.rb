module Api
  module V1
    class GlobalController < ApplicationController
      skip_before_action :authorize_request, only: [:current_location]

      def index
        render json: current_location
      end
      
    end
  end
end