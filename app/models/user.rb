class User < ApplicationRecord
  belongs_to :person
 
  def active?
    self.voided.nil?
  end

  def self.current
    Thread.current['current_user']
  end

  def self.current=(user)
    Thread.current['current_user'] = user
  end
end
