class Api::V1::DepartmentsController < ApplicationController
  before_action :set_department, only: [:show, :update, :destroy]

  def index
    @departments = Department.where(retired: 0)
    render json: @departments
  end
  
  def show
    render json: @department
  end

  def create
    name = department_params[:name]
    @department = Department.new(name: name, retired: 0, creator: User.current.id, created_date: Time.now, updated_date: Time.now)
    if @department.save
      render json: @department, status: :created, location: [:api, :v1, @department]
    else
      render json: @department.errors, status: :unprocessable_entity
    end
  end

  def update
    if @department.update(department_params)
      render json: @department, status: :ok
    else
      render json: @department.errors, status: :unprocessable_entity
    end
  end

  def destroy
    if @department.update(retired: 1, retired_by: User.current.id, retired_reason: department_params[:retired_reason], retired_date: Time.now,  updated_date: Time.now)
      render json: @department, status: :ok
  end

  private

  def set_department
    @department = Department.find(params[:id])
  end

  def department_params
    params.require(:department).permit(:name, :retired, :retired_by, :retired_reason, :retired_date, :creator, :updated_date, :created_date)
  end
end
