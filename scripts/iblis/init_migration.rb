Rails.logger = Logger.new(STDOUT)

users = Iblis.find_by_sql("SELECT * FROM users LIMIT 1")
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
  if UserManagement::UserService.username_exists? user.username
    mlab_user = User.find_by_username(user.username)
  else
    Rails.logger.info("=========Loading User: #{user.username}===========")
    mlab_user = User.new(id: user.id, person_id: person.id, username: user.username, password: user.password, is_active:0)
    if mlab_user.save!
      if !user.deleted_at.nil?
        Rails.logger.info("=========Voiding  deleted User: #{user.username}===========")
        mlab_user.update!(is_active: 1)
      end
    end 
  end
end