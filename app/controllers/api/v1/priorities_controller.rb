class Api::V1::PrioritiesController < ApplicationController
  before_action :set_priority, only: [:show, :update, :destroy]

  def index
    @priorities = Priority.all
    render json: @priorities
  end
  
  def show
    render json: @priority
  end

  def create
    @priority = Priority.new(priority_params)

    if @priority.save
      render json: @priority, status: :created, location: [:api, :v1, @priority]
    else
      render json: @priority.errors, status: :unprocessable_entity
    end
  end

  def update
    if @priority.update(priority_params)
      render json: @priority
    else
      render json: @priority.errors, status: :unprocessable_entity
    end
  end

  def destroy
    @priority.destroy
  end

  private

  def set_priority
    @priority = Priority.find(params[:id])
  end

  def priority_params
    params.require(:priority).permit(:name, :retired, :retired_by, :retired_reason, :retired_date, :creator, :updated_date, :created_date)
  end
end
