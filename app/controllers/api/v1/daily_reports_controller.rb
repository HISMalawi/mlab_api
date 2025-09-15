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
        wards = params[:wards].present? ? Reports::Moh::ReportUtils.facility_section_ids(params[:wards]) : nil
        test_type = TestType.where(nlims_code: params[:nlims_code]).where("name = '#{params[:test_type]}' OR preferred_name = '#{params[:test_type]}'").first
        max_age = params[:max_age].present? ? params[:max_age] : nil
        min_age = params[:min_age].present? ? params[:min_age] : max_age
        min_age = Date.new(UtilsService.dob(min_age).year, 1, 1) if min_age.present?
        records = Reports::DailyReport::DailyLog
                  .generate_report(report_type, {
                                     from:, to:, test_status:, department:, test_type: test_type&.id,
                                     min_age:, max_age: UtilsService.dob(max_age), wards:
                                   })
        render json: records
      end
    end
  end
end
