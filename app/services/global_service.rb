module GlobalService
  class << self
   
    def current_location
      Global.first
    end

  end
end