# frozen_string_literal: true

# module Api
module Api
  # module V1
  module V1
    # class UsersController
    class UsersController < ApplicationController
      before_action :set_user, only: %i[show update destroy activate change_username update_password]
      before_action :validate_params, only: %i[create update]
      before_action :check_username, only: [:create]

      def index
        users = user_service.users(params[:search])
        @users = users.page(params[:page]).per(params[:per_page])
        render json: {
          data: user_service.serialize_users(@users),
          meta: PaginationService.pagination_metadata(@users)
        }
      end

      def show
        render json: user_service.find_user(@user.id)
      end

      def create
        @user = user_service.create_user(user_params)
        render json: user_service.find_user(@user.id), status: :created
      end

      def update
        user_service.update_user(@user, user_params)
        unless @user.username == user_params[:user][:username]
          user_service.change_username(@user, user_params[:user][:username])
        end
        unless user_params[:user][:password].blank?
          roles = UserRoleMapping.joins(:role).where("user_role_mappings.user_id=#{User.current.id}").pluck('roles.name')
          roles = roles.map(&:downcase)
          unless roles.include?('superadmin') || roles.include?('superuser')
            raise UnAuthorized, 'You are not authorized to change password'
          end

          user_service.admin_update_password(@user, user_params[:user][:password])
        end
        render json: user_service.find_user(@user.id)
      end

      def update_password
        raise UnAuthorized, 'User not equal to logged in user' unless @user.id == User.current.id
        raise ActionController::ParameterMissing, 'for password' if params[:user][:password].blank?

        user_service.update_password(@user, user_params[:user][:old_password],
                                     user_params[:user][:password])
        render json: user_service.find_user(@user.id)
      end

      def change_username
        raise UnAuthorized, 'User not equal to logged in user' unless @user.id == User.current.id

        user_service.change_username(@user, user_params[:user][:username])
        render json: user_service.find_user(@user.id)
      end

      def destroy
        @user.deactivate
        UserManagement::AuthService.invalidate_token_version(@user)
        render json: { message: MessageService::RECORD_DELETED }
      end

      def activate
        @user.activate
        render json: { message: MessageService::RECORD_ACTIVATED }
      end

      private

      def set_user
        @user = User.find(params[:id])
      end

      def user_service
        UserManagement::UserService
      end

      def user_params
        params.permit(
          user: %i[username password old_password],
          person: %i[first_name middle_name last_name sex date_of_birth],
          roles: [],
          departments: [],
          lab_locations: []
        )
      end

      def validate_params
        validate_array_param(:roles)
        validate_array_param(:departments)
        validate_array_param(:lab_locations)
      end

      def validate_array_param(param)
        param_value = params[param]
        return if param_value.present? && param_value.is_a?(Array)

        raise ActionController::ParameterMissing, "#{param.to_s.humanize} must be an array and cannot be empty"
      end

      def check_username
        return unless user_service.username?(params[:user][:username])

        raise ActiveRecord::RecordNotUnique, 'Username already exists'
      end
    end
  end
end
