require 'test_helper'

class Api::V1::DrugOrganismMappingsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @drug_organism_mapping = drug_organism_mappings(:one)
  end

  test "should get index" do
    get api_v1_drug_organism_mappings_url, as: :json
    assert_response :success
  end

  test "should create drug_organism_mapping" do
    assert_difference('DrugOrganismMapping.count') do
      post api_v1_drug_organism_mappings_url, params: { drug_organism_mapping: { created_date: @drug_organism_mapping.created_date, creator: @drug_organism_mapping.creator, drug_id: @drug_organism_mapping.drug_id, organism_id: @drug_organism_mapping.organism_id, retired: @drug_organism_mapping.retired, retired_by: @drug_organism_mapping.retired_by, retired_date: @drug_organism_mapping.retired_date, retired_reason: @drug_organism_mapping.retired_reason, updated_date: @drug_organism_mapping.updated_date } }, as: :json
    end

    assert_response 201
  end

  test "should show drug_organism_mapping" do
    get api_v1_drug_organism_mapping_url(@drug_organism_mapping), as: :json
    assert_response :success
  end

  test "should update drug_organism_mapping" do
    patch api_v1_drug_organism_mapping_url(@drug_organism_mapping), params: { drug_organism_mapping: { created_date: @drug_organism_mapping.created_date, creator: @drug_organism_mapping.creator, drug_id: @drug_organism_mapping.drug_id, organism_id: @drug_organism_mapping.organism_id, retired: @drug_organism_mapping.retired, retired_by: @drug_organism_mapping.retired_by, retired_date: @drug_organism_mapping.retired_date, retired_reason: @drug_organism_mapping.retired_reason, updated_date: @drug_organism_mapping.updated_date } }, as: :json
    assert_response 200
  end

  test "should destroy drug_organism_mapping" do
    assert_difference('DrugOrganismMapping.count', -1) do
      delete api_v1_drug_organism_mapping_url(@drug_organism_mapping), as: :json
    end

    assert_response 204
  end
end
