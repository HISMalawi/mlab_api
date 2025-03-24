# frozen_string_literal: true

module Api
  module V1
    # SyncTestCatalogController
    class SyncTestCatalogController < ApplicationController
      def check_new_test_catalog_version
        response = ProcessTestCatalogService.check_new_version(params[:version])
        render json: response
      end

      def sync_test_catalog
        response = ProcessTestCatalogService.get_test_catalog(params[:version])
        processed = ProcessTestCatalogService.process_test_catalog(response[:catalog])
        render json: { processed: }
      end
    end
  end
end
