# frozen_string_literal: true

module Api
  module V1
    # SyncTestCatalogController
    class SyncTestCatalogController < ApplicationController
      def check_new_test_catalog_version
        response = ProcessTestCatalogService.new(params[:version]).check_new_version
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
        sections = params[:sections]&.split(',')&.map(&:strip)
        service = ProcessTestCatalogService.new(params[:version])
        response = service.test_catalog
        return render json: response unless response.present?

        processed = service.process_test_catalog(response[:catalog], sections)
        sections_synced = processed ? TestCatalogSyncTrail.where(version: params[:version]) : {}
        if processed
          TestCatalogVersion.where(is_current: true).update_all(is_current: false)
          TestCatalogVersion.find_or_create_by(version: params[:version]).update(
            version_details: response[:version_details],
            is_current: true
          )
        end
        version = TestCatalogVersion.where(is_current: true).first&.version
        render json: { processed:, sections_synced:, version: }
      end

      def test_catalog_versions
        service = ProcessTestCatalogService.new(nil)
        render json: service.test_catalog_versions
      end
    end
  end
end
