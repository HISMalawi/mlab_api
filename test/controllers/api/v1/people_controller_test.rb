require 'test_helper'

class Api::V1::PeopleControllerTest < ActionDispatch::IntegrationTest
  setup do
    @person = people(:one)
  end

  test "should get index" do
    get api_v1_people_url, as: :json
    assert_response :success
  end

  test "should create person" do
    assert_difference('Person.count') do
      post api_v1_people_url, params: { person: { birth_date_estimated: @person.birth_date_estimated, created_date: @person.created_date, creator: @person.creator, date_of_birth: @person.date_of_birth, first_name: @person.first_name, last_name: @person.last_name, middle_name: @person.middle_name, sex: @person.sex, updated_date: @person.updated_date, voided: @person.voided, voided_by: @person.voided_by, voided_date: @person.voided_date, voided_reason: @person.voided_reason } }, as: :json
    end

    assert_response 201
  end

  test "should show person" do
    get api_v1_person_url(@person), as: :json
    assert_response :success
  end

  test "should update person" do
    patch api_v1_person_url(@person), params: { person: { birth_date_estimated: @person.birth_date_estimated, created_date: @person.created_date, creator: @person.creator, date_of_birth: @person.date_of_birth, first_name: @person.first_name, last_name: @person.last_name, middle_name: @person.middle_name, sex: @person.sex, updated_date: @person.updated_date, voided: @person.voided, voided_by: @person.voided_by, voided_date: @person.voided_date, voided_reason: @person.voided_reason } }, as: :json
    assert_response 200
  end

  test "should destroy person" do
    assert_difference('Person.count', -1) do
      delete api_v1_person_url(@person), as: :json
    end

    assert_response 204
  end
end
