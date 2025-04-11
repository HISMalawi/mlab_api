# frozen_string_literal: true

# UserPreferencesController
module Api
  # Api module
  module V1
    # UserPreferencesController
    class UserPreferencesController < ApplicationController
      before_action :set_user_preference, only: %i[update show]

      def index
        @user_preferences = UserPreference.where(creator: User.current&.id)
        render json: @user_preferences
      end

      def create
        @user_preference = UserPreference.create!(user_preference_params)
        render json: @user_preference, status: :created
      end

      def update
        @user_preference.update!(user_preference_params)
        render json: @user_preference
      end

      def show
        render json: @user_preference
      end

      private

      def set_user_preference
        @user_preference = UserPreference.find(params[:id])
      end

      def user_preference_params
        params.require(:user_preference).permit(:name, :value, :voided_reason)
      end
    end
  end
end
