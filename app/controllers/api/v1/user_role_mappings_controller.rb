class Api::V1::UserRoleMappingsController < ApplicationController
  before_action :set_user_role_mapping, only: [:show, :update, :destroy]

  def index
    @user_role_mappings = UserRoleMapping.all
    render json: @user_role_mappings
  end
  
  def show
    render json: @user_role_mapping
  end

  def create
    @user_role_mapping = UserRoleMapping.new(user_role_mapping_params)

    if @user_role_mapping.save
      render json: @user_role_mapping, status: :created, location: [:api, :v1, @user_role_mapping]
    else
      render json: @user_role_mapping.errors, status: :unprocessable_entity
    end
  end

  def update
    if @user_role_mapping.update(user_role_mapping_params)
      render json: @user_role_mapping
    else
      render json: @user_role_mapping.errors, status: :unprocessable_entity
    end
  end

  def destroy
    @user_role_mapping.destroy
  end

  private

  def set_user_role_mapping
    @user_role_mapping = UserRoleMapping.find(params[:id])
  end

  def user_role_mapping_params
    params.require(:user_role_mapping).permit(:user_id, :role_id, :retired, :retired_by, :retired_reason, :retired_date, :creator, :updated_date, :created_date)
  end
end
