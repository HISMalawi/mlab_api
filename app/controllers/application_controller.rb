class ApplicationController < ActionController::API
  include ExceptionHandler
  before_action :authorize_request

  def authorize_request
    auth_token = request.headers['Authorization']
    unless auth_token
      errors = ['Authorization token required']
      raise UnAuthorized, errors
    end 
    authorized_user = UserManagement::AuthService.authenticate auth_token
    unless authorized_user
      errors = ['Invalid or expired authentication token']
      raise UnAuthorized, errors
    end
    User.current = authorized_user
    true
  end

  def paginate data
    page, limit, paginate = params[:page] || 1, params[:per_page] || 10, params[:paginate] || false
    return data if paginate
    results = PaginationService.paginate(data, page: page, limit: limit)
    {data: results, meta: PaginationService.pagination_metadata(results)}
  end

end
