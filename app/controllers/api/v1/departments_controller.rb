class Api::V1::DepartmentsController < ApplicationController
  before_action :set_department, only: [:show, :update, :destroy]
  skip_before_action :authorize_request, only: [:index]

  def index
    @departments = Department.where(retired: 0)
    render json: @departments
  end
  
  def show
    if @department.nil?
      render json: {error: true, message: MessageService::RECORD_NOT_FOUND}, status: :ok
    else
      render json: {error: false, message: MessageService::RECORD_RETRIEVED, department: @department}
    end
  end

  def create
    name = department_params[:name]
    @department = Department.new(name: name, retired: 0, creator: User.current.id, created_date: Time.now, updated_date: Time.now)
    if @department.save
      render json:  {error: false, message: MessageService::RECORD_CREATED, department: @department}, status: :created, location: [:api, :v1, @department]
    else
      render json: {error: true, message: @department.errors}, status: :unprocessable_entity
    end
  end

  def update
    if @department.nil?
      render json: {error: true, message: MessageService::RECORD_NOT_FOUND}, status: :ok
    else
      if @department.update(name: department_params[:name], updated_date: Time.now)
        render json: {error: false, message: MessageService::RECORD_UPDATED, department: @department}, status: :ok
      else
        render json: {error: true, message: @department.errors}, status: :unprocessable_entity
      end
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
    params.require(:department).permit(:name, :retired_reason)
  end
end
