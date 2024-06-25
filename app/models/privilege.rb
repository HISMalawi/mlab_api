class Privilege < RetirableRecord
  has_many :role_privilege_mappings
end
