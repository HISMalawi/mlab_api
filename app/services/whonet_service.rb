# frozen_string_literal: true

module WhonetService
  class WhoNet
    def initialize(start_date, end_date)
      @start_date = start_date.to_date.beginning_of_day
      @end_date = end_date.to_date.end_of_day
      @data = Order.find_by_sql(
        "SELECT
              p.first_name, p.last_name, p.sex AS gender, p.date_of_birth AS dob, fs.name as ward_or_location,
              o.accession_number, s.name AS specimen_type, o.requested_by, t.id as test_id, ds.organism_id
        FROM
            tests t
                INNER JOIN
            test_types tt ON tt.id=t.test_type_id
                INNER JOIN
            specimen s ON s.id = t.specimen_id
                INNER JOIN
            orders o ON o.id = t.order_id
                INNER JOIN
            encounters e ON e.id = o.encounter_id INNER JOIN facility_sections fs on fs.id=e.facility_section_id
                INNER JOIN
            clients c ON c.id = e.client_id
                INNER JOIN
            people p ON p.id = c.person_id
              LEFT JOIN drug_susceptibilities ds ON ds.test_id=t.id
        WHERE t.created_date BETWEEN '#{@start_date}' AND '#{@end_date}' AND tt.name IN ('Gram Stain', 'Culture & Sensitivity')"
      )
    end

    def get_organism(test_id, organism_id)
      result = TestResult.where(test_id:)&.first
      return Organism.find_by(id: organism_id)&.name if result&.value&.upcase == 'GROWTH' && organism_id.present?
      return nil if result&.value == '0' || result&.value.nil?

      result&.value
    end

    def drug_susceptibilities(test_id, organism_id)
      drugs = Drug.all
      drugs_json = {}
      drugs.each do |drug|
        drugs_json[drug.name.to_s] = DrugSusceptibility.find_by(test_id:, drug_id: drug.id, organism_id:)&.zone || ''
      end
      drugs_json
    end

    def process_data
      final_data = []
      @data.each do |row|
        organism = get_organism(row.test_id, row.organism_id)
        next if organism.nil?

        json_data = {
          first_name: row.first_name,
          last_name: row.last_name,
          gender: row.gender,
          dob: row.dob,
          ward_or_location: row.ward_or_location,
          accession_number: row.accession_number,
          specimen_type: row.specimen_type,
          requested_by: row.requested_by,
          test_id: row.test_id,
          organism_id: row.organism_id || ''
        }
        json_data[:organism] = organism
        final_data << json_data.merge(drug_susceptibilities(row.test_id, row.organism_id))
      end
      final_data
    end
  end
end
