module LabConfiguration::SurveillanceService 
  class << self 
    def get_surveillances(id = nil) 
      condition = ""
      condition = " WHERE sv.id IN(#{id})" if id.present?
      
      ActiveRecord::Base.connection.select_all <<~SQL 
        SELECT * FROM surveillances sv 
        INNER JOIN (SELECT id AS diseases_id, name AS disease FROM diseases) AS d ON d.diseases_id = sv.diseases_id
        INNER JOIN (SELECT id AS test_types_id, name AS test_type, short_name FROM test_types) AS tt ON tt.test_types_id = sv.test_types_id #{condition}
      SQL
    end

    def create_surveillance(surveillance_array) 
      surveillance_array.map do |sv| 
        Surveillance.find_or_create_by!(**sv)
      end
    end
  end
end