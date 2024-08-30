module Reports
  module Aggregate
    module Culture
      class Ast
        def generate_report(month:, year:)
          organisms = Organism.includes(:drugs)
          drug_susceptibility_results = fetch_drug_susceptibility_results(month, year)
          interpretations_by_organism = group_interpretations(drug_susceptibility_results)

          data = organisms.map do |organism|
            organism_data = build_organism_data(organism, interpretations_by_organism)
            organism_data if organism_data[:drugs].any?
          end.compact
          { data: }
        end

        private

        def fetch_drug_susceptibility_results(month, year)
          DrugSusceptibility
            .where('zone >= ? AND MONTH(created_date) = ? AND YEAR(created_date) = ? AND interpretation != ?', 1, month, year, '')
            .select('organism_id, drug_id, interpretation, test_id, COUNT(*) AS interpretation_count')
            .group(:organism_id, :drug_id, :interpretation)
            .pluck(:organism_id, :drug_id, :interpretation, Arel.sql('GROUP_CONCAT(test_id) AS associated_ids'),
                   Arel.sql('COUNT(*) AS interpretation_count'))
        end

        def group_interpretations(results)
          results.to_h do |(org_id, drug_id, interpretation, associated_ids, count)|
            [[org_id, drug_id, interpretation], { count:, associated_ids: }]
          end
        end

        def build_organism_data(organism, interpretations_by_organism)
          {
            name: organism.name,
            drugs: build_drugs_data(organism, interpretations_by_organism)
          }
        end

        def build_drugs_data(organism, interpretations_by_organism)
          organism.drugs.map do |drug|
            drug_data = build_drug_data(organism.id, drug, interpretations_by_organism)
            drug_data unless all_interpretations_zero?(drug_data[:interpretations])
          end.compact
        end

        def build_drug_data(organism_id, drug, interpretations_by_organism)
          {
            drug_name: drug.name,
            interpretations: %w[S R I].to_h do |interpretation|
              [interpretation,
               build_interpretation_data(organism_id, drug.id, interpretation, interpretations_by_organism)]
            end
          }
        end

        def build_interpretation_data(organism_id, drug_id, interpretation, interpretations_by_organism)
          interpretation_data = interpretations_by_organism[[organism_id, drug_id,
                                                             interpretation]] || { count: 0, associated_ids: '' }
          {
            count: interpretation_data[:count],
            associated_ids: UtilsService.insert_drilldown(interpretation_data, 'Microbiology')
          }
        end

        def all_interpretations_zero?(interpretations)
          interpretations.values.all? { |data| data[:count].zero? }
        end
      end
    end
  end
end
