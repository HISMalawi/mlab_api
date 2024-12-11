# frozen_string_literal: true

module Api
  module V1
    class GlobalController < ApplicationController
      skip_before_action :authorize_request, only: %i[index update destroy show current_git_tag nlims_status]
      before_action :set_global, only: %i[update destroy show]

      def index
        render json: GlobalService.current_location
      end

      def current_git_tag
        render json: { git_tag: }
      end

      def nlims_status
        nlims = Nlims::Sync.nlims_token
        data = {
          is_running: nlims[:ping],
          is_authenticated: nlims[:token].present?
        }
        render json: data
      end

      def create
        @global = Global.create!(global_params)
        Facility.find_or_create_by(name: @global.name)
        render json: @global, status: :created
      end

      def show
        render json: @global
      end

      def update
        @global.update!(global_params)
        Facility.find_or_create_by(name: @global.name)
        render json: @global
      end

      def destroy
        @global.void('No longer used')
        render json: { message: MessageService::RECORD_DELETED }
      end

      private

      def set_global
        @global = Global.find(params[:id])
      end

      def global_params
        params.require(:global).permit(:name, :code, :address, :phone, :district)
      end

      def git_tag
        git_describe = `git describe --tags --abbrev=0`.strip
        git_describe.empty? ? 'No tags available' : git_describe
      end
    end
  end
end
