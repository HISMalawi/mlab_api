class Api::V1::RolePrivilegeMappingsController < ApplicationController
  before_action :set_role_privilege_mapping, only: [:show, :update, :destroy]

  def index
    @role_privilege_mappings = RolePrivilegeMapping.all
    render json: @role_privilege_mappings
  end
  
  def show
    render json: @role_privilege_mapping
  end

  def create
    @role_privilege_mapping = RolePrivilegeMapping.new(role_privilege_mapping_params)

    if @role_privilege_mapping.save
      render json: @role_privilege_mapping, status: :created, location: [:api, :v1, @role_privilege_mapping]
    else
      render json: @role_privilege_mapping.errors, status: :unprocessable_entity
    end
  end

  def update
    if @role_privilege_mapping.update(role_privilege_mapping_params)
      render json: @role_privilege_mapping
    else
      render json: @role_privilege_mapping.errors, status: :unprocessable_entity
    end
  end

  def destroy
    @role_privilege_mapping.destroy
  end

  private

  def set_role_privilege_mapping
    @role_privilege_mapping = RolePrivilegeMapping.find(params[:id])
  end

  def role_privilege_mapping_params
    params.require(:role_privilege_mapping).permit(:role_id, :privilege_id, :voided, :voided_by, :voided_reason, :voided_date, :creator, :created_date, :updated_date)
  end
end
