module LabConfig
    module EncounterService
        class << self

            def create_encounter_type_facility_section_mapping(params)
                mapping_data = params[:facility_section_ids].map do |facility_section_id|
                  {
                    encounter_type_id: params[:encounter_type_id],
                    facility_section_id: facility_section_id
                  }
                end
                EncounterTypeFacilitySectionMapping.create!(mapping_data)
            end


            #This method to be refactored
            def edit_encounter_type_facility_section_mapping(id, params)
                params[:facility_section_ids].each do |facility_section_id|
                  mapping_data = {
                    encounter_type_id: params[:encounter_type_id],
                    facility_section_id: facility_section_id
                  }
                  EncounterTypeFacilitySectionMapping.find(id).update(mapping_data)
                end
            end

            def get_encounter_type_facility_section(encounter_type_id)
                if EncounterType.find(encounter_type_id)&.name == 'Referral'
                  Facility.all.select('id, name')
                else
                  EncounterTypeFacilitySectionMapping.joins(:encounter_type)
                                                   .joins(:facility_section)
                                                   .select("facility_sections.id,
                                                            facility_sections.name")
                                                   .where(encounter_type_id: encounter_type_id)
                end
            end
              
        end
    end
end 