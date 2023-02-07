class Api::V1::TestStatusesController < ApplicationController
  before_action :set_test_status, only: [:show, :update, :destroy]

  def index
    @test_statuses = TestStatus.all
    render json: @test_statuses
  end
  
  def show
    render json: @test_status
  end

  def create
    @test_status = TestStatus.new(test_status_params)

    if @test_status.save
      render json: @test_status, status: :created, location: [:api, :v1, @test_status]
    else
      render json: @test_status.errors, status: :unprocessable_entity
    end
  end

  def update
    if @test_status.update(test_status_params)
      render json: @test_status
    else
      render json: @test_status.errors, status: :unprocessable_entity
    end
  end

  def destroy
    @test_status.destroy
  end

  private

  def set_test_status
    @test_status = TestStatus.find(params[:id])
  end

  def test_status_params
    params.require(:test_status).permit(:test_id, :status_id, :status_reason_id, :creator, :voided, :voided_by, :voided_reason, :voided_date)
  end
end
