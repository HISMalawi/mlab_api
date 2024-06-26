# frozen_string_literal: true

module UserManagement
  module AuthService
    SECRET_KEY = ENV['SECRET_KEY_BASE'] || Rails.application.secrets.secret_key_base
    TOKEN_VALID_TIME = 6.hours

    class << self
      def jwt_token_encode(payload)
        JWT.encode(payload, SECRET_KEY)
      end

      def jwt_token_decode(token)
        decoded = JWT.decode(token, SECRET_KEY)[0]
        HashWithIndifferentAccess.new decoded
      end

      def basic_authentication(user, password)
        user&.password_hash == password
      end

      def user_departments(user)
        departments = []
        users_departments = UserDepartmentMapping.where(user_id: user.id)
        return nil if users_departments.nil?

        users_departments.each do |user_department|
          departments << user_department.department&.name
        end
        departments
      end

      def user_departments?(user, department)
        departments = user_departments(user)
        return false if departments.nil?

        departments.include?(department)
      end

      def authenticate(token)
        bearer_token = token.split(' ').last
        begin
          decoded = jwt_token_decode(bearer_token)
          user = User.find(decoded[:user_id])
          user if valid_token?(decoded, user.token_version) && user.active?
        rescue ActiveRecord::RecordNotFound
          false
        rescue JWT::DecodeError
          false
        end
      end

      def login(username, password, department)
        user = User.find_by('BINARY username = ?', username)
        return nil unless user&.active? && basic_authentication(user, password)
        return false unless user_departments?(user, department)

        update_sign_in_info(user)
        jwt_token_payload(user)
      end

      def jwt_token_payload(user)
        expiry_time = Time.now + TOKEN_VALID_TIME
        token = jwt_token_encode({ user_id: user.id, exp: expiry_time.to_i, token_version: user.token_version })
        {
          token:,
          expiry_time:,
          user: UserManagement::UserService.find_user(user.id)
        }
      end

      def application_login(username, password)
        user = User.find_by('BINARY username = ?', username)
        return nil unless user&.active? && basic_authentication(user, password)

        jwt_token_payload(user)
      end

      def refresh_token
        invalidate_token_version(User.current)
        update_jwt_refresh_info(User.current)
        jwt_token_payload(User.current)
      end

      def update_sign_in_info(user)
        user.update(
          sign_in_count: user.sign_in_count.to_i + 1,
          last_sign_in_at: user.current_sign_in_at,
          current_sign_in_at: Time.now,
          token_version: SecureRandom.uuid
        )
      end

      def invalidate_token_version(user)
        user&.update(token_version: SecureRandom.uuid)
      end

      def token_version_equal?(user_token_version, token_version)
        user_token_version == token_version
      end

      def token_expired?(exp)
        exp < Time.now.to_i
      end

      def valid_token?(token, user_token_version)
        !token_expired?(token[:exp]) && token_version_equal?(user_token_version, token[:token_version])
      end

      def update_jwt_refresh_info(user)
        user.update(last_jwt_refresh_at: Time.now)
      end
    end
  end
end
