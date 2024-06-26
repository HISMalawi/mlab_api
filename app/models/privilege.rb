# frozen_string_literal: true

# Privilege model
class Privilege < RetirableRecord
  has_many :role_privilege_mappings
end
