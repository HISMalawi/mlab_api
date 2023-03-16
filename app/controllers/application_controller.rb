class ApplicationController < ActionController::API
  before_action :authorize_request

  def authorize_request
    auth_token = request.headers['Authorization']
    unless auth_token
      errors = ['Authorization token required']
      render json: { errors: errors }, status: :unauthorized
      return false
    end 
    authorized_user = UserService.authenticate auth_token
    unless authorized_user
      errors = ['Invalid or expired authentication token']
      render json: { errors: errors }, status: :unauthorized
      return false
    end
    User.current = authorized_user
    true
  end

end
