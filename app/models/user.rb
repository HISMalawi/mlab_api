# frozen_string_literal: true

require 'bcrypt'

# User model
class User < VoidableRecord
  include BCrypt
  belongs_to :person
  has_many :user_department_mappings
  has_many :departments, through: :user_department_mappings
  has_many :user_role_mappings

  def active?
    is_active.zero?
  end

  def deactivate
    self.is_active = 1
    self.updated_by = User.current.id
    save!
  end

  def activate
    self.is_active = 0
    self.updated_by = User.current.id
    save!
  end

  def self.search(query)
    joins(:person)
      .where("users.username LIKE '%#{query}%' OR CONCAT(people.first_name, ' ', people.last_name) LIKE '%#{query}%'")
  end

  def full_name
    "#{person.first_name} #{person.last_name}"
  end

  def self.current
    Thread.current['current_user']
  end

  def self.current=(user)
    Thread.current['current_user'] = user
  end

  def password_hash
    @password_hash ||= Password.new(password)
  end

  def password_hash=(new_password)
    @password_hash = Password.create(new_password)
    self.password = @password_hash
  end
end
