module Reports
  module Aggregate
    module Culture
      class Ast
        def generate_report(month: nil, year: nil)
          data = {}
          organisms = Organism.includes(:drugs)
          drug_susceptibility_test_results = DrugSusceptibility.where('zone > ? AND MONTH(created_date) = ? AND YEAR(created_date) = ?', 1, month, year)
          drug_counts_by_organism = drug_susceptibility_test_results.group(:organism_id, :drug_id).pluck(:organism_id, :drug_id, Arel.sql('COUNT(*) AS drug_count')).to_h { |(org_id, drug_id, count)| [[org_id, drug_id], count] }
          organisms.each do |organism|
            organism_name = organism.name
            data[organism_name] = {
              drugs: organism.drugs.map do |drug|
                {
                  drug_name: drug.name,
                  count: drug_counts_by_organism[[organism.id, drug.id]].to_i
                }
              end
            }
          end
          drug_susceptibility_test_results
        end
      end
    end
  end
end
