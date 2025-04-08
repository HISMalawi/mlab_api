# frozen_string_literal: true

# Post crossmatch process service
# This service handles the post crossmatch process for blood transfusions
module PostCrossmatchProcessService
  # This module contains methods for managing the post crossmatch process
  class << self
    # This method creates a new post crossmatch process record
    def create_or_update_post_crossmatch_process(params)
      existing_process = PostCrossmatchProcess.find_by(test_id: params[:test_id])
      if existing_process
        existing_process.update!(params)
        existing_process
      else
        PostCrossmatchProcess.create!(params)
      end
    end
  end
end
