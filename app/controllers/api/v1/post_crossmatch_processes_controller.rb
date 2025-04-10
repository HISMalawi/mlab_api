# frozen_string_literal: true

module Api
  module V1
    # Cross process controller Controller
    class PostCrossmatchProcessesController < ApplicationController
      def create
        post_crossmatch_process = PostCrossmatchProcessService.create_or_update_post_crossmatch_process(
          post_crossmatch_process_params
          )
        render json: post_crossmatch_process, status: :created
      end

      private

      def post_crossmatch_process_params
        params.require(:post_crossmatch_process).permit(
          :facility_section_id,
          :test_id,
          :collected_by,
          :collection_date,
          :transfusion_outcome,
          :returned,
          :returned_by,
          :returned_date,
          :returned_reason
        )
      end
    end
  end
end
