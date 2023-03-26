Rails.logger = Logger.new(STDOUT)
module TestCatalog
  module IblisData
    module DrugOrganismService
      class << self
  
        def create_drug
          iblis_drugs = Iblis.find_by_sql("SELECT * FROM drugs")
          iblis_drugs.each do |drug|
            mlab_drug = Drug.new(name: drug.name, retired: 0, creator: 1, created_date: drug.created_at, updated_date: drug.updated_at)
            if mlab_drug.save
              Rails.logger.info("=========Creating Drug: #{mlab_drug.name}===========")
              if !drug.deleted_at.nil?
                drug.update(retired: 1, retired_by: 1, retired_date: drug.deleted_at, retired_reason: 'deleted', updated_date: drug.updated_at)
              end
            end
          end
        end
  
        def create_organism
          iblis_organisms = Iblis.find_by_sql("SELECT * FROM organisms")
          iblis_organisms.each do |organism|
            mlab_organism = Organism.new(name: organism.name, description: organism.description, retired: 0, creator: 1, created_date: organism.created_at, updated_date: organism.updated_at)
            if mlab_organism.save
              Rails.logger.info("=========Creating Organism: #{mlab_organism.name}===========")
              if !organism.deleted_at.nil?
                organism.update(retired: 1, retired_by: 1, retired_date: organism.deleted_at, retired_reason: 'deleted', updated_date: organism.updated_at)
              end
            end
          end
        end
  
        def drug_organism_mapping
          iblis_drug_organisms = Iblis.find_by_sql("SELECT 
            d.name AS drug,
            o.name AS organism,
            od.deleted_at,
            o.created_at,
            o.updated_at
                FROM
            organism_drugs od
                INNER JOIN
            organisms o ON o.id = od.organism_id
                INNER JOIN
            drugs d ON d.id = od.drug_id")
          iblis_drug_organisms.each do |drug_organism|
            drug = Drug.find_by_name(drug_organism.drug)
            organism = Organism.find_by_name(drug_organism.organism)
            mlab_drug_organism_mapping = DrugOrganismMapping.new(drug_id: drug.id, organism_id: organism.id, retired: 0, creator: 1, created_date: drug_organism.created_at, updated_date: drug_organism.updated_at)
            if mlab_drug_organism_mapping.save
              Rails.logger.info("=========Mapping Drug: #{drug.name}===========to Organism: #{organism.name} ======")
              if !drug_organism.deleted_at.nil?
                mlab_drug_organism_mapping.update(retired: 1, retired_by: 1, retired_date: drug_organism.deleted_at, retired_reason: 'deleted', updated_date: drug_organism.updated_at)
              end
            end
          end
        end
  
      end  
    end
  end
end