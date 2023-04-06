# frozen_string_literal: true
require 'bcrypt'

class User < VoidableRecord
  include BCrypt
  belongs_to :person
 
  def active?
    self.is_active == 0
  end

  def deactivate
    self.is_active = 1
    self.updated_by = User.current.id
    self.save!
  end

  def activate
    self.is_active = 0
    self.updated_by = User.current.id
    self.save!
  end

  def self.current
    Thread.current['current_user']
  end

  def self.current=(user)
    Thread.current['current_user'] = user
  end

  def password_hash
    @password ||= Password.new(password)
  end

  def password_hash=(new_password)
    @password = Password.create(new_password)
    self.password = @password
  end

end
