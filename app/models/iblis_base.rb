class IblisBase < ActiveRecord::Base
  self.abstract_class = true
  establish_connection(:iblis_db)
end