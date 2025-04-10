# frozen_string_literal: true

# API V1 module for whonet Report Controller
module Api
  module V1
    # Controller that handles all requests pertaining to whonet Reports
    class WhonetController < ApplicationController
      def whonet_report
        data = WhonetService::WhoNet.new(params.require(:start_date), params.require(:end_date)).process_data
        render json: data
      end

      def whonet_report_csv
        csv = WhonetService::WhoNet.new(params.require(:start_date), params.require(:end_date)).generate_csv
        send_data csv, filename: "whonet_report_#{params.require(:start_date)}_to_#{params.require(:end_date)}.csv"
      end
    end
  end
end
