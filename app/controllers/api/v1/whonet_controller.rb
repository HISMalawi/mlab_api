# frozen_string_literal: true

# API V1 module for whonet Report Controller
module Api
  module V1
    # Controller that handles all requests pertaining to whonet Reports
    class WhonetController < ApplicationController
      def whonet_report
        data = WhonetService::WhoNet.new(params[:start_date], params[:end_date]).process_data
        render json: data
      end
    end
  end
end
