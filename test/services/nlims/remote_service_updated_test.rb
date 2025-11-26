require 'test_helper'

class Nlims::RemoteServiceUpdatedTest < ActiveSupport::TestCase
  def setup
    @service = Nlims::RemoteService.new
  end

  test "find_specimen_by_nlims_code_or_name prioritizes nlims_code" do
    # Create test specimens
    specimen1 = Specimen.create!(name: 'Blood Sample', nlims_code: 'NLIMS_SP_001')
    specimen2 = Specimen.create!(name: 'Blood Sample', nlims_code: 'NLIMS_SP_002')

    sample_type = {
      'nlims_code' => 'NLIMS_SP_002',
      'name' => 'Blood Sample'
    }

    result = @service.find_specimen_by_nlims_code_or_name(sample_type)
    assert_equal specimen2.id, result.id, "Should find specimen by nlims_code, not name"
  end

  test "find_test_type_by_nlims_code_or_name prioritizes nlims_code" do
    # Create test types
    test_type1 = TestType.create!(name: 'Full Blood Count', nlims_code: 'NLIMS_TT_001')
    test_type2 = TestType.create!(name: 'Full Blood Count', nlims_code: 'NLIMS_TT_002')

    test_type_data = {
      'nlims_code' => 'NLIMS_TT_002',
      'name' => 'Full Blood Count'
    }

    result = @service.find_test_type_by_nlims_code_or_name(test_type_data)
    assert_equal test_type2.id, result.id, "Should find test type by nlims_code, not name"
  end

  test "find_test_indicator_by_nlims_code_or_name prioritizes nlims_code" do
    # Create test indicators
    indicator1 = TestIndicator.create!(name: 'Hemoglobin', nlims_code: 'NLIMS_TI_001')
    indicator2 = TestIndicator.create!(name: 'Hemoglobin', nlims_code: 'NLIMS_TI_002')

    measure_data = {
      'nlims_code' => 'NLIMS_TI_002',
      'name' => 'Hemoglobin'
    }

    result = @service.find_test_indicator_by_nlims_code_or_name(measure_data)
    assert_equal indicator2.id, result.id, "Should find test indicator by nlims_code, not name"
  end

  test "merge_or_create_order handles new payload structure" do
    # Setup required data
    LabLocation.create!(name: 'Main Lab') if LabLocation.count == 0
    Status.create!(name: 'specimen-accepted') if Status.find_by(name: 'specimen-accepted').nil?
    Priority.create!(name: 'Routine') if Priority.find_by(name: 'Routine').nil?
    EncounterType.create!(name: 'Referral') if EncounterType.find_by(name: 'Referral').nil?
    ClientIdentifierType.create!(name: 'npid') if ClientIdentifierType.find_by(name: 'npid').nil?
    
    specimen = Specimen.create!(name: 'Venous Whole Blood', nlims_code: 'NLIMS_SP_0003_MWI')
    test_type = TestType.create!(name: 'Full Blood Count', nlims_code: 'NLIMS_TT_0035_MWI')

    payload = {
      'order' => {
        'uuid' => 'b97a7258-10bb-47f4-accf-b49cad2328f8',
        'tracking_number' => 'XKCH2500874465',
        'sample_type' => {
          'nlims_code' => 'NLIMS_SP_0003_MWI',
          'name' => 'Venous Whole Blood'
        },
        'priority' => 'Routine',
        'date_created' => '2025-02-22T20:35:06.000+02:00'
      },
      'patient' => {
        'national_patient_id' => 'Unknown',
        'first_name' => 'Eflida',
        'last_name' => 'Madalitso',
        'gender' => 'Female',
        'date_of_birth' => '1990-01-01'
      },
      'tests' => [
        {
          'test_type' => {
            'nlims_code' => 'NLIMS_TT_0035_MWI',
            'name' => 'Full Blood Count'
          }
        }
      ],
      'lab_location' => 1
    }

    # This should not raise an error and should create an order
    assert_nothing_raised do
      order = @service.merge_or_create_order(payload)
      assert_not_nil order
      assert_equal 'XKCH2500874465', order.tracking_number
    end
  end
end
