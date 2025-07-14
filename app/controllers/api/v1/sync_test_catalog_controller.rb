# frozen_string_literal: true

module Api
  module V1
    # SyncTestCatalogController
    class SyncTestCatalogController < ApplicationController
      def check_new_test_catalog_version
        response = ProcessTestCatalogService.check_new_version(params[:version])
        render json: response
      end

      # Syncs test catalog data from NLIMS
      # @param version [String] version of the test catalog to sync
      # @param sections [String] optional comma-separated list of sections to sync:
      #   - test_types: includes test indicators and target turnaround time (TAT)
      #   - specimens: specimen types associated with tests
      #   - organisms: organisms and their related drugs
      #   - lab_test_sites: laboratory test sites
      # If no sections parameter is provided, all sections will be synced
      def sync_test_catalog
        response = ProcessTestCatalogService.get_test_catalog(params[:version])
        sections = params[:sections]&.split(',')&.map(&:strip)
        processed = ProcessTestCatalogService.process_test_catalog(response[:catalog], sections)
        render json: { processed: }
      end

      def get_test_catalog_versions
        response = ProcessTestCatalogService.get_test_catalog_versions
        render json: response
      end
    end
  end
end
