class User < VoidableRecord
  belongs_to :person
 
  def active?
    self.voided == 0
  end

  def self.current
    Thread.current['current_user']
  end

  def self.current=(user)
    Thread.current['current_user'] = user
  end
end
