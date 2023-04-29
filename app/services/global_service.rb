module GlobalService
  class << self
   
    def current_location
      location = YAML.load_file("#{Rails.root}/config/application.yml")['facility']
    end

  end
end