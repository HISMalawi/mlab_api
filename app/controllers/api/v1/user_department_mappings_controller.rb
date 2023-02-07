class Api::V1::UserDepartmentMappingsController < ApplicationController
  before_action :set_user_department_mapping, only: [:show, :update, :destroy]

  def index
    @user_department_mappings = UserDepartmentMapping.all
    render json: @user_department_mappings
  end
  
  def show
    render json: @user_department_mapping
  end

  def create
    @user_department_mapping = UserDepartmentMapping.new(user_department_mapping_params)

    if @user_department_mapping.save
      render json: @user_department_mapping, status: :created, location: [:api, :v1, @user_department_mapping]
    else
      render json: @user_department_mapping.errors, status: :unprocessable_entity
    end
  end

  def update
    if @user_department_mapping.update(user_department_mapping_params)
      render json: @user_department_mapping
    else
      render json: @user_department_mapping.errors, status: :unprocessable_entity
    end
  end

  def destroy
    @user_department_mapping.destroy
  end

  private

  def set_user_department_mapping
    @user_department_mapping = UserDepartmentMapping.find(params[:id])
  end

  def user_department_mapping_params
    params.require(:user_department_mapping).permit(:user_id, :department_id, :retired, :retired_by, :retired_reason, :retired_date, :creator, :updated_date, :created_date)
  end
end
