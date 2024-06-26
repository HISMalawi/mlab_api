# frozen_string_literal: true

# ApplicationController
class ApplicationController < ActionController::API
  include ExceptionHandler
  before_action :authorize_request

  def authorize_request
    auth_token = request.headers['Authorization']
    raise UnAuthorized, ['Authorization token required'] unless auth_token

    auth_user = UserManagement::AuthService.authenticate(auth_token)
    raise UnAuthorized, ['Invalid or expired authentication token'] unless auth_user

    User.current = auth_user
    true
  end

  def paginate(data)
    page = params[:page] || 1
    limit = params[:per_page] || 10
    paginate = params[:paginate] || false
    return data if paginate

    results = PaginationService.paginate(data, page:, limit:)
    { data: results, meta: PaginationService.pagination_metadata(results) }
  end
end
