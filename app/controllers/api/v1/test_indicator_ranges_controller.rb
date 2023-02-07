class Api::V1::TestIndicatorRangesController < ApplicationController
  before_action :set_test_indicator_range, only: [:show, :update, :destroy]

  def index
    @test_indicator_ranges = TestIndicatorRange.all
    render json: @test_indicator_ranges
  end
  
  def show
    render json: @test_indicator_range
  end

  def create
    @test_indicator_range = TestIndicatorRange.new(test_indicator_range_params)

    if @test_indicator_range.save
      render json: @test_indicator_range, status: :created, location: [:api, :v1, @test_indicator_range]
    else
      render json: @test_indicator_range.errors, status: :unprocessable_entity
    end
  end

  def update
    if @test_indicator_range.update(test_indicator_range_params)
      render json: @test_indicator_range
    else
      render json: @test_indicator_range.errors, status: :unprocessable_entity
    end
  end

  def destroy
    @test_indicator_range.destroy
  end

  private

  def set_test_indicator_range
    @test_indicator_range = TestIndicatorRange.find(params[:id])
  end

  def test_indicator_range_params
    params.require(:test_indicator_range).permit(:test_indicator_id, :min_age, :max_age, :sex, :lower_range, :upper_range, :interpretation, :value, :retired, :retired_by, :retired_reason, :retired_date, :creator, :created_date, :updated_date)
  end
end
