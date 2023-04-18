Rails.logger = Logger.new(STDOUT)
ActiveRecord::Base.transaction do
  # Load Users
  users = Iblis.find_by_sql("SELECT * FROM users")
  users.each do |user|
    sex = user.gender == 0 ? 'M' : 'F'
    name = user.name.split()
    middle_name = ''
    if name.length > 1
      first_name = name[0]
      last_name = name.length> 2 ? name[2] : name[1]
      middle_name = name[1] if name.length > 2
    else
      first_name = name[0]
      last_name = name[0]
    end
    person = Person.where(first_name: first_name, last_name: last_name, sex: sex, created_date: user.created_at, updated_date: user.updated_at).first
    if person.nil?
      Rails.logger.info("=========Loading Person: #{user.name}===========")
      person = Person.create!(first_name: first_name, middle_name: middle_name, last_name: last_name, sex: sex, created_date: user.created_at, updated_date: user.updated_at)
    end
    if UserService.username_exists? user.username
      mlab_user = User.find_by_username(user.username)
    else
      Rails.logger.info("=========Loading User: #{user.username}===========")
      mlab_user = User.new(person_id: person.id, username: user.username, password: user.password, is_active:0)
      if mlab_user.save!
        if !user.deleted_at.nil?
          Rails.logger.info("=========Voiding  deleted User: #{user.username}===========")
          mlab_user.update!(is_active: 1)
        end
      end 
    end

    # Load Roles
    roles = Iblis.find_by_sql("SELECT * FROM  roles")
    roles.each do |role|
      if Role.find_by_name(role.name).nil?
        Rails.logger.info("=========Loading Role: #{role.name}===========")
        Role.create!(name: role.name, created_date: role.created_at, updated_date: role.updated_at, creator: mlab_user.id)
      end
    end
    # Load User Role mapping
    user_roles_sql = "SELECT distinct(u.username), r.name AS role FROM assigned_roles ar INNER JOIN roles r on r.id = ar.role_id 
                    INNER JOIN users u ON u.id=user_id WHERE u.name = '#{user.name.gsub("'", "\\\\'")}' AND u.updated_at = '#{user.updated_at}'"
    user_roles = Iblis.find_by_sql(user_roles_sql)
    user_roles.each do |user_role|
      role = Role.find_by_name(user_role.role)
      if UserRoleMapping.where(role_id: role.id, user_id: mlab_user.id).first.nil?
        Rails.logger.info("=========Loading User Role For: #{user_role.username}===========")
        UserRoleMapping.create!(role_id: role.id, user_id: mlab_user.id, creator: mlab_user.id)
      end
    end
  end

  user_ = User.all.first
  # Load departments
  departments = Iblis.find_by_sql("SELECT * FROM test_categories")
  departments.each do |department|
    if Department.find_by_name(department.name).nil?
      Rails.logger.info("=========Loading department: #{department.name}===========")
      Department.create!(name: department.name, created_date: department.created_at, updated_date: department.updated_at, creator: user_.id)
    end
  end
  # Map User to department
  users_departments = Iblis.find_by_sql("SELECT tc.name AS dept, u.username AS user FROM user_testcategory utc INNER JOIN test_categories tc ON tc.id = utc.test_category_id INNER JOIN users u ON u.id=utc.user_id")
  users_departments.each do |u_dpt|
    user = User.find_by_username(u_dpt.user)&.id
    department = Department.find_by_name(u_dpt.dept)
    if UserDepartmentMapping.where(user_id: user, department_id: department.id, creator: user_.id).first.nil?
      Rails.logger.info("=========Mapping user: #{u_dpt.user} to department: #{u_dpt.dept}===========")
      UserDepartmentMapping.create!(user_id: user, department_id: department.id, creator: user_.id) unless user.nil?
    end
  end
  Role.update_all(creator: user_.id)
  Person.update_all(creator: user_.id)
  User.update_all(creator: user_.id)
  Department.update_all(creator: user_.id)
  UserDepartmentMapping.update_all(creator: user_.id)
end


