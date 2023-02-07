class Api::V1::TestTypesController < ApplicationController
  before_action :set_test_type, only: [:show, :update, :destroy]

  def index
    @test_types = TestType.all
    render json: @test_types
  end
  
  def show
    render json: @test_type
  end

  def create
    @test_type = TestType.new(test_type_params)

    if @test_type.save
      render json: @test_type, status: :created, location: [:api, :v1, @test_type]
    else
      render json: @test_type.errors, status: :unprocessable_entity
    end
  end

  def update
    if @test_type.update(test_type_params)
      render json: @test_type
    else
      render json: @test_type.errors, status: :unprocessable_entity
    end
  end

  def destroy
    @test_type.destroy
  end

  private

  def set_test_type
    @test_type = TestType.find(params[:id])
  end

  def test_type_params
    params.require(:test_type).permit(:name, :department_id, :expected_turn_around_time, :retired, :retired_by, :retired_reason, :retired_date, :creator, :updated_date, :created_date)
  end
end
