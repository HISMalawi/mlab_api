# frozen_string_literal: true

module UserManagement
  module UserService 
  
    class << self
      def create_user(first_name:, middle_name:, last_name:, sex:, date_of_birth:, birth_date_estimated:, username:, password:, roles:, departments:)
        ActiveRecord::Base.transaction do
          person = PersonService.create_person(first_name: first_name, middle_name: middle_name, last_name: last_name, sex: sex, date_of_birth: date_of_birth, birth_date_estimated: birth_date_estimated)
          user = User.new(person_id: person.id, username: username)
          user.password = BCrypt::Password.create(password)
          if user.save!
            roles.each do |role|
              create_role( user.id, role)
            end
            departments.each do |department|
              create_department(user.id, department)
            end
            user
          end
        end
      end
  
      def create_role(user_id, role_id)
        UserRoleMapping.create!(role_id: role_id, user_id: user_id)
      end
  
      def create_department(user_id, department_id)
        UserDepartmentMapping.create!(department_id: department_id, user_id: user_id)
      end
  
      def update_user(user, params)
        ActiveRecord::Base.transaction do 
          person = user.person 
          updated_person = PersonService.update_person(person: person, first_name: params[:first_name], middle_name: params[:middle_name], 
            last_name: params[:last_name], sex: params[:sex], date_of_birth: params[:date_of_birth], birth_date_estimated: params[:birth_date_estimated])
          if updated_person
            update_roles(user.id, params[:roles])
            update_departments(user.id, params[:departments])
          end
          user
        end
      end
  
      def update_roles(user_id, role_ids)
        UserRoleMapping.where(user_id: user_id).where.not(role_id: role_ids).each do |user_role_mapping|
          user_role_mapping.void('Role removed from user')
        end
        role_ids.each do |role_id|
          UserRoleMapping.find_or_create_by(role_id: role_id, user_id: user_id)
        end
      end
  
      def update_departments(user_id, department_ids)
        UserDepartmentMapping.where(user_id: user_id).where.not(department_id: department_ids).each do |user_department_mapping|
          user_department_mapping.void('Department removed from user')
        end
        department_ids.each do |department_id|
          UserDepartmentMapping.find_or_create_by(department_id: department_id, user_id: user_id)
        end
      end
  
  
      def update_password(user, old_password, new_password)
        if !basic_authentication(user, old_password)
          raise ActiveRecord::RecordInvalid, "Your old password is incorrect"
        else
          user.last_password_changed = user.password
          user.password = BCrypt::Password.create(new_password)
          user.save!
        end
      end
  
      def change_username(user, username)
          if username_exists?(username)
            raise ActiveRecord::RecordNotUnique, "Username already exists"
          else
            user.username = username
            user.save!
          end
      end
  
      def calculate_birth_date_estimate(age)
        Date.today - age.years
      end
  
      def void_user(user, void_reason)
        ActiveRecord::Base.transaction do
          user.void(void_reason)
          user_departments = UserDepartmentMapping.where(user_id: user.id)
          user_departments.each do |user_department|
            user_department.void(void_reason)
          end
          user_roles = UserRoleMapping.where(user_id: user.id)
          user_roles.each do |user_role|
            user_role.void(void_reason)
          end
        end
      end
  
      def find_user(id)
        user = User.joins(:person).select('users.id, username, first_name, middle_name, last_name, sex, date_of_birth, birth_date_estimated, users.voided, users.voided_reason').where(id: id).first
        return nil if user.nil?
        roles = UserRoleMapping.joins(:user, :role).where(user_id: id).select('roles.id, roles.name, user_role_mappings.retired, user_role_mappings.retired_reason')
        departments = UserDepartmentMapping.joins(:user, :department).where(user_id: id).select('departments.id, departments.name, user_department_mappings.retired, user_department_mappings.retired_reason')
        serialize(user, roles, departments)
      end
  
      def username_exists?(username)
        user = User.find_by_username(username)
        return false if user.nil?
        true
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
          voided: user.voided,
          voided_reason: user.voided_reason,
          roles: roles,
          departments: departments
        }
      end
  
      def serialize_users(users)
        users_a = []
        users.each do |user|
          users_a.push({
            id: user.id,
            username: user.username,
            first_name: user.person.first_name,
            middle_name: user.person.middle_name,
            last_name: user.person.last_name,
            sex: user.person.sex,
            date_of_birth: user.person.date_of_birth,
            birth_date_estimated: user.person.birth_date_estimated,
            create_date: user.person.created_date
          })
        end
        users_a
      end
  
    end
  end
end