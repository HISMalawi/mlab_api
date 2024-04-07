class ArticlesController < ActionController::Base
  def index
    test_service = Tests::TestService.new
    @test_service = test_service.client_report(106199, nil, nil, 373405)
    @test_service = {data: @test_service, facility: GlobalService.current_location }
  end
end