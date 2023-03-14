class Api::V1::DrugsController < ApplicationController
  before_action :set_drug, only: [:show, :update, :destroy]

  def index
    @drugs = Drug.where(retired: 0)
    render json: @drugs
  end
  
  def show
    render json: @drug
  end

  def create
    @drug = Drug.new(short_name: drug_params[:short_name], name: drug_params[:name], creator: User.current.id, retired: 0, created_date: Time.now, updated_date: Time.now)

    if @drug.save
      render json: @drug, status: :created, location: [:api, :v1, @drug]
    else
      render json: @drug.errors, status: :unprocessable_entity
    end
  end

  def update
    if @drug.update(name: drug_params[:name], short_name: drug_params[:short_name],  updated_date: Time.now)
      render json: @drug, status: :ok
    else
      render json: @drug.errors, status: :unprocessable_entity
    end
  end

  def destroy
    if @drug.update(retired: 1, retired_by: User.current.id, retired_reason: drug_params[:retired_reason], retired_date: Time.now, updated_date: Time.now)
      render json: @drug, status: :ok
    else
      render json: @drug.errors, status: :unprocessable_entity
   end
  end

  private

  def set_drug
    @drug = Drug.find(params[:id])
  end

  def drug_params
    params.require(:drug).permit(:short_name, :name, :retired, :retired_by, :retired_reason, :retired_date, :creator, :updated_date, :created_date)
  end
end
