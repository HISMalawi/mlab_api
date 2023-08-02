module Reports
  module Aggregate
    module Culture
      class Ast
        def generate_report(month: nil, year: nil)
          data = []
          organisms = Organism.includes(:drugs)
          drug_susceptibility_test_results = DrugSusceptibility.where('zone > ? AND MONTH(created_date) = ? AND YEAR(created_date) = ? AND interpretation != ?', 1, month, year, '')
          interpretations_by_organism = drug_susceptibility_test_results.group(:organism_id, :drug_id, :interpretation).pluck(:organism_id, :drug_id, :interpretation, Arel.sql('COUNT(*) AS interpretation_count')).to_h { |(org_id, drug_id, interpretation, count)| [[org_id, drug_id, interpretation], count] }
          organisms.each do |organism|
            organism_name = organism.name
            data << {
              name: organism_name,
              drugs: organism.drugs.map do |drug|
                drug_id = drug.id
                interpretation_s_count = interpretations_by_organism[[organism.id, drug_id, 'S']].to_i
                interpretation_r_count = interpretations_by_organism[[organism.id, drug_id, 'R']].to_i
                interpretation_i_count = interpretations_by_organism[[organism.id, drug_id, 'I']].to_i

                {
                  drug_name: drug.name,
                  interpretations: {
                    'S' => interpretation_s_count,
                    'R' => interpretation_r_count,
                    'I' => interpretation_i_count
                  }
                }
              end
            }
          end
          data
        end
      end
    end
  end
end
