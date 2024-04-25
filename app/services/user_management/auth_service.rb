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
        user.password_hash == password
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
        return departments.include?(department)
      end

      def authenticate(token)
        bearer_token = token.split(' ').last
        begin
          decoded = jwt_token_decode(bearer_token)
          current_user = User.find(decoded[:user_id])
          return false if decoded[:exp] < Time.now.to_i
          current_user
        rescue ActiveRecord::RecordNotFound => e
          return false
        rescue JWT::DecodeError => e
          return false
        end
      end

      def login(username, password, department)
        user = User.find_by("BINARY username = ?", username)
        if user && user.active? &&  basic_authentication(user, password)
           unless user_departments?(user, department)
            return false
           end
          exp = Time.now + TOKEN_VALID_TIME
          return {token: jwt_token_encode({user_id: user.id, exp: exp.to_i}), expiry_time: exp, user: UserManagement::UserService.find_user(user.id)}
        else
          return nil
        end
      end

      def application_login(username, password)
        user = User.find_by("BINARY username = ?", username)
        unless user && user.active? &&  basic_authentication(user, password)
          return nil
        end
        exp = Time.now + TOKEN_VALID_TIME
        return {token: jwt_token_encode({user_id: user.id, exp: exp.to_i}), expiry_time: exp, user: UserManagement::UserService.find_user(user.id)}
      end

      def refresh_token
        exp = Time.now + TOKEN_VALID_TIME
        {
          token: UserManagement::AuthService.jwt_token_encode(user_id: User.current.id, exp: exp.to_i),
          expiry_time: exp,
          user: UserManagement::UserService.find_user(User.current.id)
        }
      end

    end
  end
end
