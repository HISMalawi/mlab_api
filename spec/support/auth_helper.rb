# frozen_string_literal: true

module AuthHelper
  class << self
    def http_login
      @http_login ||= begin
        token = UserManagement::AuthService.jwt_token_encode({ user_id: User.first })
        "Bearer #{token}"
      end
    end
  end
end
