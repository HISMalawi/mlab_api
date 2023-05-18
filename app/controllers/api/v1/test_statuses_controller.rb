class Api::V1::TestStatusesController < ApplicationController
  before_action :test_status, only: %i[not_received pending completed started verified voided not_done rejected]

  def index
    test_id = params.require(:test_id)
    render json: TestStatus.find_by_test_id(test_id)
  end

  def get_test_statuses
    render json: Status.where("name not like '%specimen%'")
  end


  def not_received
    status = Status.find_by_name("not-received")
    render json: update_status(status)
  end
  
  def pending
    status = Status.find_by_name("pending")
    render json: update_status(status)
  end
  
  def completed
    status = Status.find_by_name("completed")
    render json: update_status(status)
  end
  
  def started
    status = Status.find_by_name("started")
    render json: update_status(status)
  end
  
  def verified
    status = Status.find_by_name("verified")
    render json: update_status(status)
  end
  
  def voided
    status = Status.find_by_name("voided")
    render json: update_status(status)
  end
  
  def not_done
    status = Status.find_by_name("not-done")
    render json: update_status(status)
  end
  
  def rejected
    status = Status.find_by_name("test-rejected")
    render json: update_status(status)
  end

  private

  def test_status
    TestStatus.find_by(test_id: params.require(:test_id))
  end

  def person_talked_to
    params[:person_talked_to]
  end

  def reason
    params[:status_reason_id]
  end

  def update_status(status)
    updated = TestCatalog::TestStatusesService.update_test_status(test_status, status, reason, person_talked_to)
    return Test.find(params.require(:test_id)) if updated
    updated
  end

  def test_status_params
    params.permit(:test_id, :status_id)
  end
end
