class Api::V1::TestsController < ApplicationController
  def index
    render json: paginate(test_service.find_tests(params[:search], params[:department_id]))
  end
  
  def show
    render json: Test.find(params[:id])
  end

  def create
    test = Test.create!(test_params)
    render json: test, status: :created
  end

  def report
    from, to, order_id = params.values_at(:from, :to, :order_id)
    render json: test_service.client_report(Client.find(params[:client_id]), from, to, order_id), status: :ok
  end

  def update
    Test.find(params[:id]).update!(test_params)
    render json: Test.find(params[:id]), status: :ok
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
