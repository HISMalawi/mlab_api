class Api::V1::TestsController < ApplicationController
  def index
    render json: paginate(test_service.find_tests(params[:search]))
  end
  
  def show
    render json: Test.find(params[:id])
  end

  def create
    Test.create!(test_params)
  end

  def update
    Test.find(params[:id]).update!(test_params)
  end

  def destroy
    @test.void(params[:retired_reason])
    render json: {message: MessageService::RECORD_DELETED}
  end

  private

  def test_service
    Tests::TestService.new
  end

  def test_params
    params.permit(:specimen_id, :order_id, :test_type_id)
  end
end
