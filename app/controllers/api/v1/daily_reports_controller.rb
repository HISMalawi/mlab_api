# frozen_string_literal: true

# API module
module Api
  # V1 module
  module V1
    # Controller for handling Daily reports requests
    class DailyReportsController < ApplicationController

      def daily_log
        render json: { message: 'daily'}
      end
    end
  end
end
