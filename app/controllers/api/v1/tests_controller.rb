class Api::V1::TestsController < ApplicationController
  before_action :set_test, only: [:show, :update, :destroy]

  def index
    @tests = Test.all
    render json: @tests
  end
  
  def show
    render json: @test
  end

  def create
    @test = Test.new(test_params)

    if @test.save
      render json: @test, status: :created, location: [:api, :v1, @test]
    else
      render json: @test.errors, status: :unprocessable_entity
    end
  end

  def update
    if @test.update(test_params)
      render json: @test
    else
      render json: @test.errors, status: :unprocessable_entity
    end
  end

  def destroy
    @test.destroy
  end

  private

  def set_test
    @test = Test.find(params[:id])
  end

  def test_params
    params.require(:test).permit(:specimen_id, :order_id, :test_type_id, :voided, :voided_by, :voided_reason, :voided_date, :creator, :created_date, :updated_date)
  end
end
