# frozen_string_literal: true

# user lab location mapping model
class UserLabLocationMapping < VoidableRecord
  belongs_to :user
  belongs_to :lab_location
end
