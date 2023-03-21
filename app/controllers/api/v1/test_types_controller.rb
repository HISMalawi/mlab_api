class Api::V1::TestTypesController < ApplicationController
  before_action :set_test_type, only: [:show, :update, :destroy]

  def index
    @test_types = TestType.where(retired: 0)
    render json: @test_types
  end
  
  def test_indicator_types
    render json: {error: false, message: MessageService::RECORD_RETRIEVED, test_indicator_types: TestIndicator.test_indicator_types}, status: :ok
  end 

  def show
    if @test_type.nil?
      render json: {error: true, message: "Record Not Found"}
    else
      test_type = TestCatalog::TestTypeService.show(@test_type)
      render json: test_type 
    end
  end

  def create
    perform_create = TestCatalog::TestTypeService.create(test_type_params)
    if perform_create[:status]
      render json: perform_create, status: :created
    else
      render json: perform_create, status: :unprocessable_entity
    end
  end

  def update
    TestCatalog::TestTypeService.update(@test_type, test_type_params)
  end

  def destroy
    if @test_type.nil?
      render json: {error: true, message: MessageService::RECORD_NOT_FOUND}
    else
     TestCatalog::TestTypeService.delete(@test_type, test_type_params[:retired_reason])
     render json: {error: false, message: MessageService::RECORD_DELETED}, status: :ok
    end
  end

  private

  def set_test_type
    begin
      @test_type = TestType.find(params[:id])
    rescue => e
      @test_type = nil
    end
  end

  def test_type_params
    params
  end
end
