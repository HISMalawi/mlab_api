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
              create_role(user.id, role)
            end
            user_params[:departments].each do |department|
              create_department(user.id, department)
            end
            user_params[:lab_locations].each do |location|
              create_lab_location(user.id, location)
            end
            user
          end
        end
      end

      def create_role(user_id, role_id)
        UserRoleMapping.create!(role_id:, user_id:)
      end

      def create_department(user_id, department_id)
        UserDepartmentMapping.create!(department_id:, user_id:)
      end

      def create_lab_location(user_id, lab_location_id)
        UserLabLocationMapping.create!(user_id:, lab_location_id:)
      end

      def update_user(user, user_params)
        ActiveRecord::Base.transaction do
          person = user.person
          updated_person = person.update!(user_params[:person])
          if updated_person
            person.update!(first_name_soundex: person.first_name.soundex, last_name_soundex: person.last_name.soundex)
            update_roles(user.id, user_params[:roles])
            update_departments(user.id, user_params[:departments])
            update_lab_locations(user.id, user_params[:lab_locations])
          end
          user
        end
      end

      def update_roles(user_id, role_ids)
        UserRoleMapping.where(user_id:).where.not(role_id: role_ids).each do |user_role_mapping|
          user_role_mapping.void('Role removed from user')
        end
        role_ids.each do |role_id|
          UserRoleMapping.find_or_create_by(role_id:, user_id:)
        end
      end

      def update_departments(user_id, department_ids)
        UserDepartmentMapping.where(user_id:).where.not(department_id: department_ids).each do |user_department_mapping|
          user_department_mapping.void('Department removed from user')
        end
        department_ids.each do |department_id|
          UserDepartmentMapping.find_or_create_by(department_id:, user_id:)
        end
      end

      def update_lab_locations(user_id, lab_location_ids)
        UserLabLocationMapping.where(user_id:).where.not(lab_location_id: lab_location_ids).each do |mapping|
          mapping.void('lab_location removed from user')
        end
        lab_location_ids.each do |lab_location_id|
          UserLabLocationMapping.find_or_create_by(lab_location_id:, user_id:)
        end
      end

      def admin_update_password(user, new_password)
        user.last_password_changed = Time.now
        user.password_hash = new_password
        user.save!
      end

      def update_password(user, old_password, new_password)
        unless UserManagement::AuthService.basic_authentication(user, old_password)
          raise ActiveRecord::RecordNotUnique, 'Your old password is incorrect'
        end

        user.last_password_changed = Time.now
        user.password_hash = new_password
        user.save!
      end

      def change_username(user, username)
        raise ActiveRecord::RecordNotUnique, 'Username already exists' if username_exists?(username)

        raise ActionController::ParameterMissing, 'for username' if username.blank?

        user.username = username
        user.save!
      end

      def find_user(id)
        user = User.joins(:person).select('users.id, username, first_name, middle_name, last_name, sex, date_of_birth, birth_date_estimated, users.is_active, users.voided, users.voided_reason').where(id:).first
        return nil if user.nil?

        roles = UserRoleMapping.joins(:user,
                                      :role).where(user_id: id).select('roles.id, roles.name, user_role_mappings.retired, user_role_mappings.retired_reason, user_role_mappings.role_id')
        departments = UserDepartmentMapping.joins(:user,
                                                  :department).where(user_id: id).select('departments.id, departments.name, user_department_mappings.retired, user_department_mappings.retired_reason')
        serialize(user, roles, departments)
      end

      def username_exists?(username)
        user = User.find_by_username(username)
        return false if user.nil?

        true
      end

      # rubocop:disable Metrics/MethodLength
      def serialize(user, roles, departments)
        {
          id: user.id,
          username: user.username,
          first_name: user.first_name,
          middle_name: user.middle_name,
          last_name: user.last_name,
          sex: user.sex,
          is_active: user.is_active.zero?,
          date_of_birth: user.date_of_birth,
          birth_date_estimated: user.birth_date_estimated,
          voided: user.voided,
          voided_reason: user.voided_reason,
          roles:,
          permissions: user_privileges(user),
          departments:,
          lab_locations: lab_locations(user.id)
        }
      end
      # rubocop:enable Metrics/MethodLength

      def user_privileges(user)
        user_roles = user.user_role_mappings.pluck(:role_id)
        privileges = Privilege.where(id: RolePrivilegeMapping.where(role_id: user_roles).pluck(:privilege_id))
        privileges.select('id, name, display_name')
      end

      def lab_locations(user_id)
        UserLabLocationMapping.joins(:lab_location).select('lab_locations.id, lab_locations.name').where(user_id:)
      end

      def users(query)
        @users = User.all
        @users = User.search(params[:search]) if query.present?
        @users
      end

      def serialize_users(users)
        users_a = []
        users.each do |user|
          users_a.push({
                         id: user.id,
                         username: user.username,
                         is_active: user.is_active == 0,
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
