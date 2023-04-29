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
    page, limit = params[:page] || 1, params[:per_page] || 10
    results = PaginationService.paginate(data, page: page, limit: limit)
    {data: results, meta: PaginationService.pagination_metadata(results)}
  end

  def current_location
    location = YAML.load_file("#{Rails.root}/config/application.yml")['facility']
  end

end
