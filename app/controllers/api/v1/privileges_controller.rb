class Api::V1::PrivilegesController < ApplicationController
  before_action :set_privilege, only: [:show, :update, :destroy]

  def index
    @privileges = Privilege.all
    render json: @privileges
  end
  
  def show
    render json: @privilege
  end

  def create
    @privilege = Privilege.new(privilege_params)

    if @privilege.save
      render json: @privilege, status: :created, location: [:api, :v1, @privilege]
    else
      render json: @privilege.errors, status: :unprocessable_entity
    end
  end

  def update
    if @privilege.update(privilege_params)
      render json: @privilege
    else
      render json: @privilege.errors, status: :unprocessable_entity
    end
  end

  def destroy
    @privilege.destroy
  end

  private

  def set_privilege
    @privilege = Privilege.find(params[:id])
  end

  def privilege_params
    params.require(:privilege).permit(:name, :retired, :retired_by, :retired_reason, :retired_date, :creator, :updated_date, :created_date)
  end
end
