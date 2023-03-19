class Api::V1::TestTypesController < ApplicationController
  before_action :set_test_type, only: [:show, :update, :destroy]

  def index
    @test_types = TestType.where(retired: 0)
    render json: @test_types
  end
  
  def show
    render json: @test_type
  end

  def create
    perform_create = TestCatalog::TestTypeService.create(test_type_params)
    if perform_create[:status]
      perform_create[:testtype] = TestType.where(retired: 0).last
      render json: perform_create, status: :created
    else
      render json: perform_create, status: :unprocessable_entity
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
    params
  end
end
