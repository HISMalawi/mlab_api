class Api::V1::TestIndicatorsController < ApplicationController
  before_action :set_test_indicator, only: [:show, :update, :destroy]

  def index
    @test_indicators = TestIndicator.all
    render json: @test_indicators
  end
  
  def show
    render json: @test_indicator
  end

  def create
    @test_indicator = TestIndicator.new(test_indicator_params)

    if @test_indicator.save
      render json: @test_indicator, status: :created, location: [:api, :v1, @test_indicator]
    else
      render json: @test_indicator.errors, status: :unprocessable_entity
    end
  end

  def update
    if @test_indicator.update(test_indicator_params)
      render json: @test_indicator
    else
      render json: @test_indicator.errors, status: :unprocessable_entity
    end
  end

  def destroy
    @test_indicator.destroy
  end

  private

  def set_test_indicator
    @test_indicator = TestIndicator.find(params[:id])
  end

  def test_indicator_params
    params.require(:test_indicator).permit(:name, :test_type_id, :test_indicator_type, :unit, :description, :retired, :retired_by, :retired_reason, :retired_date, :creator, :created_date, :updated_date)
  end
end
