class UserRoleMapping < RetirableRecord
  belongs_to :user
  belongs_to :role

  def as_json(options = {})
    super(options.merge(methods: %i[role_name], only: %i[id role_id user_id]))
  end

  def role_name
    role.name
  end

end
