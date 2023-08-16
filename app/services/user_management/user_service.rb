# frozen_string_literal: true

require 'bantu_soundex'

module UserManagement
  module UserService

    class << self
      def create_user(user_params)
        ActiveRecord::Base.transaction do
          person = Person.create!(user_params[:person])
          person.update!(first_name_soundex: person.first_name.soundex, last_name_soundex: person.last_name.soundex)
          user = User.new(user_params[:user])
          user.person = person
          user.is_active = 0
          user.password_hash = user_params[:user][:password]
          if user.save!
            user_params[:roles].each do |role|
              create_role( user.id, role)
            end
            user_params[:departments].each do |department|
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

      def update_user(user, user_params)
        ActiveRecord::Base.transaction do
          person = user.person
          updated_person = person.update!(user_params[:person])
          if updated_person
            person.update!(first_name_soundex: person.first_name.soundex, last_name_soundex: person.last_name.soundex)
            update_roles(user.id, user_params[:roles])
            update_departments(user.id, user_params[:departments])
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
        unless UserManagement::AuthService.basic_authentication(user, old_password)
          raise ActiveRecord::RecordNotUnique, "Your old password is incorrect"
        else
          user.last_password_changed = Time.now
          user.password_hash = new_password
          user.save!
        end
      end

      def change_username(user, username)
          if username_exists?(username)
            raise ActiveRecord::RecordNotUnique, "Username already exists"
          else
            raise ActionController::ParameterMissing, "for username" if username.blank?
            user.username = username
            user.save!
          end
      end

      def find_user(id)
        user = User.joins(:person).select('users.id, username, first_name, middle_name, last_name, sex, date_of_birth, birth_date_estimated, users.is_active, users.voided, users.voided_reason').where(id: id).first
        return nil if user.nil?
        roles = UserRoleMapping.joins(:user, :role).where(user_id: id).select('roles.id, roles.name, user_role_mappings.retired, user_role_mappings.retired_reason, user_role_mappings.role_id')
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
          is_active: user.is_active == 0 ? true : false,
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
            is_active: user.is_active == 0 ? true : false,
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
