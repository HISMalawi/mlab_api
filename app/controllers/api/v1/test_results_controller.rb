class Api::V1::TestResultsController < ApplicationController
  before_action :set_test_result, only: [:show, :update, :destroy]

  def index
    @test_results = TestResult.all
    render json: @test_results
  end
  
  def show
    render json: @test_result
  end

  def create
    @test_result = TestResult.new(test_result_params)

    if @test_result.save
      render json: @test_result, status: :created, location: [:api, :v1, @test_result]
    else
      render json: @test_result.errors, status: :unprocessable_entity
    end
  end

  def update
    if @test_result.update(test_result_params)
      render json: @test_result
    else
      render json: @test_result.errors, status: :unprocessable_entity
    end
  end

  def destroy
    @test_result.destroy
  end

  private

  def set_test_result
    @test_result = TestResult.find(params[:id])
  end

  def test_result_params
    params.require(:test_result).permit(:test_id, :test_indicator_id, :value, :result_date, :voided, :voided_by, :voided_reason, :voided_date, :creator, :created_date, :updated_date)
  end
end
