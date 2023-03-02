require 'bcrypt'

module UserService 
  SECRET_KEY = Rails.application.secrets.secret_key_base
  TOKEN_VALID_TIME = 24.hours.from_now
  
  class << self
    def create_user(first_name:, middle_name: '', last_name:, sex:, date_of_birth: '', birth_date_estimated: '', username:, password:, roles:, departments:)
      person = PersonService.create_person(first_name: first_name, middle_name: middle_name, last_name: last_name, sex: sex, date_of_birth: date_of_birth, birth_date_estimated: birth_date_estimated)
      user = User.new(person_id: person.id, username: username, creator: User.current, created_date: Time.now, updated_date: Time.now)
      user.password = BCrypt::Password.create(password)
      user.save!
      roles.each do |role|
        UserRoleMapping.create(role_id: role, user_id: user.id)
      end
      departments.each do |department|
        UserDepartmentMapping.create(department_id: department, user_id: user.id)
      end
      return find_user(user.id)
    end

    def update_user(user, params)
      updated_person = PersonService.update_person(first_name: params[first_name], middle_name: params[middle_name], last_name: params[last_name], sex: params[sex], date_of_birth: params[date_of_birth], birth_date_estimated: params[birth_date_estimated])
      if updated_person
        person = user.person 
        person.updated_date = Time.now
        person.save
      end
      
    end

    def find_user(id)
      user = User.joins(:person).select('users.id, username, first_name, middle_name, last_name, sex','date_of_birth','birth_date_estimated').where(id: id).first
      return nil if user.nil?
      roles = UserRoleMapping.joins(:user, :role).where(user_id: id).select('roles.id, roles.name')
      departments = UserDepartmentMapping.joins(:user, :department).where(user_id: id).select('departments.id, departments.name')
      serialize(user, roles, departments)
    end

    def username_exists?(username)
      user = User.find_by_username(username)
      return false if user.nil?
      true
    end

    def deactivate_user(user, voided_reason)
      user_update = user.update(voided: 1, voided_by: User.current.id, voided_reason: voided_reason, voided_date: Time.now)
      return true if user_update
      false
    end

    def activate_user(user, voided_reason)
      user_update = user.update(voided: nil, voided_by: nil, voided_reason: nil, voided_date: nil)
      return true if user_update
      false
    end

    def basic_authentication(user, password)
      BCrypt::Password.new(user.password) == password
    end

    def authenticate(token)
      begin
        decoded = jwt_token_decode(token)
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
      user = User.find_by_username(username)
      if user && user.active? &&  basic_authentication(user, password)
        return false if user_departments?(user, department)
        return {token: jwt_token_encode(user_id: user.id), expiry_time: Time.now + TOKEN_VALID_TIME, user: user}
      else
        return nil
      end
    end

    def user_departments(user)
      users_departments = UserDepartmentMapping.where(user_id: user.id)
      if users_departments.nil?
        return nil
      else
        departments = []
        users_departments.each do |user_department|
          departments.push(user_department.department.name)
        end
      end
      departments
    end

    def user_departments?(user, department)
      user_departments(user).include?(department)
    end

    def jwt_token_encode(payload)
      payload[:exp] = TOKEN_VALID_TIME.to_i
      JWT.encode(payload, SECRET_KEY)
    end

    def jwt_token_decode(token)
      decoded = JWT.decode(token, SECRET_KEY)[0]
      HashWithIndifferentAccess.new decoded
    end

    def serialize(user, roles, departments)
      {
        id: user.id,
        username: user.username,
        first_name: user.first_name,
        middle_name: user.middle_name,
        last_name: user.last_name,
        sex: user.sex,
        date_of_birth: user.date_of_birth,
        birth_date_estimated: user.birth_date_estimated,
        roles: roles,
        departments: departments
      }
    end

  end
end