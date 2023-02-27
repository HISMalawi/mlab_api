Rails.logger = Logger.new(STDOUT)
ActiveRecord::Base.transaction do
 # Load Roles
  roles = Iblis.find_by_sql("SELECT * FROM  roles")
  roles.each do |role|
   Rails.logger.info("=========Loading Role: #{role.name}===========")
   Role.create(name: role.name, created_date: role.created_at, updated_date: role.updated_at)
  end
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
    Rails.logger.info("=========Loading Person: #{user.name}===========")
    person = Person.create(first_name: first_name, middle_name: middle_name, last_name: last_name, sex: sex, 
                created_date: user.created_at, updated_date: user.updated_at)

    user_roles_sql = "SELECT distinct(u.username), u.name AS name, r.name AS role, u.created_at, u.updated_at, u.password 
                    FROM assigned_roles ar INNER JOIN roles r on r.id = ar.role_id 
                    INNER JOIN users u ON u.id=user_id WHERE u.name = '#{user.name.gsub("'", "\\\\'")}' AND u.updated_at = '#{user.updated_at}'"
    user_roles = Iblis.find_by_sql(user_roles_sql)

    user_roles.each do |user_role|
      role = Role.find_by_name(user_role.role)
      Rails.logger.info("=========Loading User: #{user_role.username}===========")
      User.create(role_id: role.id, person_id: person.id, username: user_role.username, password: user_role.password, 
        created_date: user.created_at, updated_date: user.updated_at)
    end
  end
  # Load departments
  departments = Iblis.find_by_sql("SELECT * FROM test_categories")
  departments.each do |department|
    Rails.logger.info("=========Loading department: #{department.name}===========")
    Department.create(name: department.name, created_date: department.created_at, updated_date: department.updated_at)
  end
  # Map User to department
  users_departments = Iblis.find_by_sql("SELECT tc.name AS dept, u.username AS user FROM user_testcategory utc INNER JOIN test_categories tc ON tc.id = utc.test_category_id INNER JOIN users u ON u.id=utc.user_id")
  users_departments.each do |u_dpt|
    Rails.logger.info("=========Mapping user: #{u_dpt.user} to department: #{u_dpt.dept}===========")
    user = User.find_by_username(u_dpt.user)
    department = Department.find_by_name(u_dpt.dept)
    UserDepartmentMapping.create(user_id: user.id, department_id: department.id, created_date: Time.now, updated_date: Time.now) unless user.nil?
  end
  Role.update_all(creator: 1)
  Person.update_all(creator: 1)
  User.update_all(creator: 1)
  Department.update_all(creator: 1)
  UserDepartmentMapping.update_all(creator: 1)
end


