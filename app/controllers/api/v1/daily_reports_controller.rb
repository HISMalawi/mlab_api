# frozen_string_literal: true

# API module
module Api
  # V1 module
  module V1
    # Controller for handling Daily reports requests
    class DailyReportsController < ApplicationController
      def daily_log
        from = params[:from]
        to = params[:to]
        department = params[:department]
        test_status = params[:test_status]
        report_type = params[:report_type]
        records = Reports::DailyReport::DailyLog
            .generate_report(report_type,{from:, to:, test_status:, department:})
        render json: records
      end
    end
  end
end
