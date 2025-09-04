class Role < RetirableRecord
  validates :name, uniqueness: true, presence: true
  has_many :role_privilege_mappings, dependent: :destroy
  has_many :privileges, through: :role_privilege_mappings
end
