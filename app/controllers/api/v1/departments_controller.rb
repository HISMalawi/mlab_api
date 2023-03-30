class Api::V1::DepartmentsController < ApplicationController
  before_action :set_department, only: [:show, :update, :destroy]
  skip_before_action :authorize_request, only: [:index]

  def index
    @departments = Department.where(retired: 0)
    render json: @departments
  end
  
  def show
    render json: @departments
  end

  def create
    @department = Department.create!(department_params)
    render json: @department, status: :created
  end

  def update
    if @department.update!(department_params)
      render json: @department
    end
  end

  def destroy
    if @department.nil?
      render json: {error: true, message: MessageService::RECORD_NOT_FOUND}
    else
      if @department.update(retired: 1, retired_by: User.current.id, retired_reason: department_params[:retired_reason], retired_date: Time.now,  updated_date: Time.now)
        render json: {error: false, message: MessageService::RECORD_DELETED}, status: :ok
      end
    end
  end

  private

  def set_department
    begin
      @department = Department.find(params[:id])
    rescue => exception
      @department = nil
    end
  end

  def department_params
    params.require(:department).permit(:name)
  end
end
