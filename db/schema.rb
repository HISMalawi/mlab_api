# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.0].define(version: 0) do
  create_table "client_identifier_types", primary_key: "client_identifier_type_id", charset: "utf8mb3", force: :cascade do |t|
    t.string "name", limit: 45
    t.integer "retired", limit: 1
    t.bigint "retired_by"
    t.string "retired_reason"
    t.datetime "retired_date", precision: nil
    t.bigint "creator"
    t.datetime "created_date", precision: nil
    t.datetime "updated_date", precision: nil
    t.index ["name"], name: "name_UNIQUE", unique: true
  end

  create_table "client_identifiers", primary_key: "client_identifier_id", charset: "utf8mb3", force: :cascade do |t|
    t.bigint "client_identifier_type_id"
    t.string "value", null: false
    t.bigint "client_id"
    t.integer "voided", limit: 1
    t.bigint "voided_by"
    t.string "voided_reason"
    t.datetime "voided_date", precision: nil
    t.bigint "creator"
    t.datetime "created_date", precision: nil
    t.bigint "updated_date"
    t.string "uuid", limit: 36
    t.index ["client_id"], name: "client_identifier_client_fk_idx"
    t.index ["client_identifier_type_id"], name: "client_identifiers_type_fk_idx"
  end

  create_table "client_order_print_trails", primary_key: "client_order_print_trail_id", charset: "utf8mb3", force: :cascade do |t|
    t.bigint "order_id"
    t.bigint "creator"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.integer "voided", limit: 1
    t.bigint "voided_by"
    t.string "voided_reason"
    t.datetime "voided_date", precision: nil
    t.index ["order_id"], name: "client_order_print_trail_order_fk_idx"
  end

  create_table "clients", primary_key: "client_id", charset: "utf8mb3", force: :cascade do |t|
    t.bigint "person_id"
    t.binary "uuid", limit: 1
    t.integer "voided", limit: 1
    t.bigint "voided_by"
    t.string "voided_reason"
    t.datetime "voided_date", precision: nil
    t.bigint "creator"
    t.datetime "created_date", precision: nil
    t.bigint "updated_date"
    t.index ["person_id"], name: "client_person_fk_idx"
  end

  create_table "culture_observations", primary_key: "culture_observation_id", charset: "utf8mb3", force: :cascade do |t|
    t.bigint "test_id"
    t.text "description", size: :medium
    t.datetime "observation_datetime", precision: nil
    t.integer "voided", limit: 1
    t.bigint "voided_by"
    t.string "voided_reason"
    t.datetime "voided_date", precision: nil
    t.bigint "creator"
    t.datetime "created_date", precision: nil
    t.datetime "updated_date", precision: nil
    t.index ["test_id"], name: "culture_observations_test_fk_idx"
  end

  create_table "departments", primary_key: "department_id", charset: "utf8mb3", force: :cascade do |t|
    t.string "name"
    t.integer "retired", limit: 1
    t.bigint "retired_by"
    t.string "retired_reason"
    t.datetime "retired_date", precision: nil
    t.bigint "creator"
    t.datetime "updated_date", precision: nil
    t.datetime "created_date", precision: nil
  end

  create_table "drug_organism_mapping", primary_key: "drug_organism_mapping_id", charset: "utf8mb3", force: :cascade do |t|
    t.bigint "drug_id"
    t.bigint "organism_id"
    t.integer "retired", limit: 1
    t.bigint "retired_by"
    t.string "retired_reason"
    t.datetime "retired_date", precision: nil
    t.bigint "creator"
    t.datetime "updated_date", precision: nil
    t.datetime "created_date", precision: nil
    t.index ["drug_id"], name: "drug_organism_mapping_drug_fk_idx"
    t.index ["organism_id"], name: "drug_organism_mapping_organism_fk_idx"
  end

  create_table "drug_susceptibility_test_results", primary_key: "drug_susceptibility_test_result_id", charset: "utf8mb3", force: :cascade do |t|
    t.bigint "drug_id"
    t.bigint "organism_id"
    t.integer "zone"
    t.column "interpretation", "enum('S','I','R')"
    t.bigint "test_id"
    t.integer "voided", limit: 1
    t.bigint "voided_by"
    t.string "voided_reason"
    t.datetime "voided_date", precision: nil
    t.bigint "creator"
    t.datetime "created_date", precision: nil
    t.datetime "updated_date", precision: nil
    t.index ["drug_id"], name: "drug_susceptibility_test_result_drug_fk_idx"
    t.index ["organism_id"], name: "drug_susceptibility_test_result_organism_fk_idx"
    t.index ["test_id"], name: "drug_susceptibility_test_result_test_fk_idx"
  end

  create_table "drugs", primary_key: "drug_id", charset: "utf8mb3", force: :cascade do |t|
    t.string "short_name"
    t.string "name"
    t.integer "retired", limit: 1
    t.bigint "retired_by"
    t.string "retired_reason"
    t.datetime "retired_date", precision: nil
    t.bigint "creator"
    t.datetime "updated_date", precision: nil
    t.datetime "created_date", precision: nil
  end

  create_table "encounters", primary_key: "encounter_id", id: :bigint, default: nil, charset: "utf8mb3", force: :cascade do |t|
    t.bigint "facility_id"
    t.bigint "destination_id"
    t.datetime "start_date", precision: nil
    t.datetime "end_date", precision: nil
    t.bigint "location_id"
    t.string "patient_id"
    t.bigint "facility_section_id"
    t.bigint "client_id"
    t.integer "voided", limit: 1
    t.bigint "voided_by"
    t.string "voided_reason"
    t.datetime "voided_date", precision: nil
    t.bigint "creator"
    t.datetime "created_date", precision: nil
    t.bigint "updated_date"
    t.string "uuid", limit: 36
    t.index ["client_id"], name: "encounters_client_fk_idx"
    t.index ["facility_id"], name: "visit_facility_fk_idx"
    t.index ["facility_section_id"], name: "visit_facility_section_fk_idx"
  end

  create_table "facilities", primary_key: "facility_id", charset: "utf8mb3", force: :cascade do |t|
    t.string "name", limit: 45
    t.integer "retired", limit: 1
    t.bigint "retired_by"
    t.string "retired_reason"
    t.datetime "retired_date", precision: nil
    t.bigint "creator"
    t.datetime "created_date", precision: nil
    t.datetime "updated_date", precision: nil
  end

  create_table "facility_sections", primary_key: "facility_section_id", charset: "utf8mb3", force: :cascade do |t|
    t.string "name"
    t.integer "retired", limit: 1
    t.bigint "retired_by"
    t.string "retired_reason"
    t.datetime "retired_date", precision: nil
    t.bigint "creator"
    t.datetime "created_date", precision: nil
    t.datetime "updated_date", precision: nil
  end

  create_table "instrument_test_type_mapping", primary_key: "instrument_test_type_mapping_id", charset: "utf8mb3", force: :cascade do |t|
    t.bigint "instrument_id"
    t.bigint "test_type_id"
    t.integer "retired", limit: 1
    t.bigint "retired_by"
    t.string "retired_reason"
    t.datetime "retired_date", precision: nil
    t.bigint "creator"
    t.datetime "created_date", precision: nil
    t.datetime "updated_date", precision: nil
    t.index ["instrument_id"], name: "instrument_test_type_mapping_instrument_id_idx"
    t.index ["test_type_id"], name: "instrument_test_type_mapping_test_type_fk_idx"
  end

  create_table "instruments", primary_key: "instrument_id", charset: "utf8mb3", force: :cascade do |t|
    t.string "name"
    t.string "description"
    t.string "ip_address", limit: 45
    t.string "hostname", limit: 45
    t.integer "retired", limit: 1
    t.bigint "retired_by"
    t.string "retired_reason"
    t.datetime "retired_date", precision: nil
    t.bigint "creator"
    t.datetime "created_date", precision: nil
    t.datetime "updated_date", precision: nil
    t.index ["name"], name: "name_UNIQUE", unique: true
  end

  create_table "orders", primary_key: "order_id", id: :bigint, default: nil, charset: "utf8mb3", force: :cascade do |t|
    t.bigint "encounter_id"
    t.bigint "priority_id"
    t.string "accession_number"
    t.string "tracking_number"
    t.string "requested_by"
    t.datetime "sample_collected_time", precision: nil
    t.string "collected_by"
    t.bigint "creator"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.integer "voided", limit: 1
    t.bigint "voided_by"
    t.string "voided_reason"
    t.datetime "voided_date", precision: nil
    t.index ["accession_number"], name: "accession_number_UNIQUE", unique: true
    t.index ["encounter_id"], name: "visit_order_fk_idx"
    t.index ["priority_id"], name: "order_priority_fk_idx"
  end

  create_table "organisms", primary_key: "organism_id", charset: "utf8mb3", force: :cascade do |t|
    t.string "name"
    t.string "description"
    t.integer "retired", limit: 1
    t.bigint "retired_by"
    t.string "retired_reason"
    t.datetime "retired_date", precision: nil
    t.bigint "creator"
    t.datetime "updated_date", precision: nil
    t.datetime "created_date", precision: nil
  end

  create_table "person", primary_key: "person_id", charset: "utf8mb3", force: :cascade do |t|
    t.string "first_name"
    t.string "middle_name"
    t.string "last_name"
    t.string "sex", limit: 10
    t.date "date_of_birth"
    t.integer "birth_date_estimated", limit: 1
    t.integer "voided", limit: 1
    t.bigint "voided_by"
    t.string "voided_reason"
    t.datetime "voided_date", precision: nil
    t.bigint "creator"
    t.datetime "created_date", precision: nil
    t.bigint "updated_date"
  end

  create_table "priorities", primary_key: "priority_id", charset: "utf8mb3", force: :cascade do |t|
    t.string "name", limit: 45
    t.integer "retired", limit: 1
    t.bigint "retired_by"
    t.string "retired_reason"
    t.datetime "retired_date", precision: nil
    t.bigint "creator"
    t.datetime "updated_date", precision: nil
    t.datetime "created_date", precision: nil
  end

  create_table "privileges", primary_key: "privilege_id", charset: "utf8mb3", force: :cascade do |t|
    t.bigint "name"
    t.integer "retired", limit: 1
    t.bigint "retired_by"
    t.string "retired_reason"
    t.datetime "retired_date", precision: nil
    t.bigint "creator"
    t.datetime "updated_date", precision: nil
    t.datetime "created_date", precision: nil
  end

  create_table "role_privilege_mapping", primary_key: "role_privilege_mapping_id", charset: "utf8mb3", force: :cascade do |t|
    t.bigint "role_id"
    t.bigint "privilege_id"
    t.integer "voided", limit: 1
    t.bigint "voided_by"
    t.string "voided_reason"
    t.datetime "voided_date", precision: nil
    t.bigint "creator"
    t.datetime "created_date", precision: nil
    t.bigint "updated_date"
    t.index ["privilege_id"], name: "privilege_role_fk_idx1"
    t.index ["role_id"], name: "privilege_role_fk_idx"
  end

  create_table "roles", primary_key: "role_id", charset: "utf8mb3", force: :cascade do |t|
    t.string "name", limit: 45
    t.integer "retired", limit: 1
    t.bigint "retired_by"
    t.string "retired_reason"
    t.datetime "retired_date", precision: nil
    t.bigint "creator"
    t.datetime "updated_date", precision: nil
    t.datetime "created_date", precision: nil
  end

  create_table "specimen_test_type_mapping", primary_key: "specimen_test_type_mapping_id", charset: "utf8mb3", force: :cascade do |t|
    t.bigint "specimen_id"
    t.bigint "test_type_id"
    t.integer "retired", limit: 1
    t.bigint "retired_by"
    t.string "retired_reason"
    t.datetime "retired_date", precision: nil
    t.bigint "creator"
    t.datetime "updated_date", precision: nil
    t.datetime "created_date", precision: nil
    t.index ["specimen_id"], name: "specimen_test_type_maps_specimen_fk_idx"
    t.index ["test_type_id"], name: "specimen_test_type_maps_test_type_id_idx"
  end

  create_table "specimens", primary_key: "specimen_id", id: :bigint, default: nil, charset: "utf8mb3", force: :cascade do |t|
    t.string "name"
    t.integer "retired", limit: 1
    t.bigint "retired_by"
    t.string "retired_reason"
    t.datetime "retired_date", precision: nil
    t.bigint "creator"
    t.datetime "created_date", precision: nil
    t.datetime "updated_date", precision: nil
    t.index ["name"], name: "name_UNIQUE", unique: true
  end

  create_table "statuses", primary_key: "status_id", id: :bigint, default: nil, charset: "utf8mb3", force: :cascade do |t|
    t.string "name"
    t.integer "retired", limit: 1
    t.bigint "retired_by"
    t.string "retired_reason"
    t.datetime "retired_date", precision: nil
    t.bigint "creator"
    t.datetime "updated_date", precision: nil
    t.datetime "updated_date_copy1", precision: nil
  end

  create_table "test_indicator_ranges", primary_key: "test_indicator_range_id", charset: "utf8mb3", force: :cascade do |t|
    t.bigint "test_indicator_id"
    t.integer "min_age"
    t.integer "max_age"
    t.string "sex", limit: 1
    t.bigint "lower_range"
    t.bigint "upper_range"
    t.string "interpretation"
    t.string "value"
    t.integer "retired", limit: 1
    t.bigint "retired_by"
    t.string "retired_reason"
    t.datetime "retired_date", precision: nil
    t.bigint "creator"
    t.datetime "created_date", precision: nil
    t.datetime "updated_date", precision: nil
    t.index ["test_indicator_id"], name: "test_indicator_range_tst_indicaor_fk_idx"
  end

  create_table "test_indicators", primary_key: "test_indicator_id", charset: "utf8mb3", force: :cascade do |t|
    t.string "name"
    t.bigint "test_type_id"
    t.column "test_indicator_type", "enum('AutoComplete','Numeric','Free Text','AlphaNumeric')"
    t.string "unit", limit: 45
    t.string "description"
    t.integer "retired", limit: 1
    t.bigint "retired_by"
    t.string "retired_reason"
    t.datetime "retired_date", precision: nil
    t.bigint "creator"
    t.datetime "created_date", precision: nil
    t.datetime "updated_date", precision: nil
    t.index ["test_type_id"], name: "test_indicators_test_type_fk_idx"
  end

  create_table "test_panels", primary_key: "test_panel_id", charset: "utf8mb3", force: :cascade do |t|
    t.string "name"
    t.string "description"
    t.integer "retired", limit: 1
    t.bigint "retired_by"
    t.string "retired_reason"
    t.datetime "retired_date", precision: nil
    t.bigint "creator"
    t.datetime "updated_date", precision: nil
    t.datetime "created_date", precision: nil
  end

  create_table "test_results", primary_key: "test_result_id", charset: "utf8mb3", force: :cascade do |t|
    t.bigint "test_id"
    t.bigint "test_indicator_id"
    t.text "value", size: :medium
    t.datetime "result_date", precision: nil
    t.integer "voided", limit: 1
    t.bigint "voided_by"
    t.string "voided_reason"
    t.datetime "voided_date", precision: nil
    t.bigint "creator"
    t.datetime "created_date", precision: nil
    t.datetime "updated_date", precision: nil
    t.index ["test_id"], name: "test_result_test_fk_idx"
    t.index ["test_indicator_id"], name: "test_result_test_indicator_fk_idx"
  end

  create_table "test_status_reasons", primary_key: "test_status_reason_id", charset: "utf8mb3", force: :cascade do |t|
    t.string "description"
  end

  create_table "test_statuses", primary_key: "test_status_id", charset: "utf8mb3", force: :cascade do |t|
    t.bigint "test_id"
    t.bigint "status_id"
    t.bigint "status_reason_id"
    t.bigint "creator"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.integer "voided", limit: 1
    t.bigint "voided_by"
    t.string "voided_reason"
    t.datetime "voided_date", precision: nil
    t.index ["status_id"], name: "test_statuses_status_fk_idx"
    t.index ["status_reason_id"], name: "test_statuses_reason_fk_idx"
    t.index ["test_id"], name: "test_statuses_test_fk_idx"
  end

  create_table "test_type_panel_mapping", primary_key: "test_type_panel_mapping_id", charset: "utf8mb3", force: :cascade do |t|
    t.bigint "test_type_id"
    t.bigint "test_pannel_id"
    t.integer "voided", limit: 1
    t.bigint "voided_by"
    t.string "voided_reason"
    t.datetime "voided_date", precision: nil
    t.bigint "creator"
    t.datetime "created_date", precision: nil
    t.datetime "updated_date", precision: nil
    t.index ["test_pannel_id"], name: "test_type_panel_mapping_test_panel_fk_idx"
    t.index ["test_type_id"], name: "test_type_panel_mapping_test_type_fk_idx"
  end

  create_table "test_types", primary_key: "test_type_id", charset: "utf8mb3", force: :cascade do |t|
    t.string "name"
    t.bigint "department_id"
    t.decimal "expected_turn_around_time", precision: 10
    t.integer "retired", limit: 1
    t.bigint "retired_by"
    t.string "retired_reason"
    t.datetime "retired_date", precision: nil
    t.bigint "creator"
    t.datetime "updated_date", precision: nil
    t.datetime "created_date", precision: nil
    t.index ["department_id"], name: "test_type_department_fk_idx"
  end

  create_table "tests", primary_key: "test_id", charset: "utf8mb3", force: :cascade do |t|
    t.bigint "specimen_id"
    t.bigint "order_id"
    t.bigint "test_type_id"
    t.integer "voided", limit: 1
    t.bigint "voided_by"
    t.string "voided_reason"
    t.datetime "voided_date", precision: nil
    t.bigint "creator"
    t.datetime "created_date", precision: nil
    t.datetime "updated_date", precision: nil
    t.index ["order_id"], name: "specimen_order_fk_idx"
    t.index ["specimen_id"], name: "specimen_tests_fk_idx"
    t.index ["test_type_id"], name: "test_test_types_fk_idx"
  end

  create_table "user_department_mapping", primary_key: "user_department_mapping_id", charset: "utf8mb3", force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "department_id"
    t.integer "retired", limit: 1
    t.bigint "retired_by"
    t.string "retired_reason"
    t.datetime "retired_date", precision: nil
    t.bigint "creator"
    t.datetime "updated_date", precision: nil
    t.datetime "created_date", precision: nil
    t.index ["department_id"], name: "user_department_idx"
    t.index ["user_id"], name: "department_user_fk_idx"
  end

  create_table "users", primary_key: "user_id", charset: "utf8mb3", force: :cascade do |t|
    t.bigint "role_id"
    t.bigint "person_id"
    t.string "username"
    t.string "password"
    t.string "last_password_changed"
    t.integer "voided", limit: 1
    t.bigint "voided_by"
    t.string "voided_reason"
    t.datetime "voided_date", precision: nil
    t.bigint "creator"
    t.datetime "created_date", precision: nil
    t.bigint "updated_date"
    t.index ["person_id"], name: "user_person_fk_idx"
    t.index ["role_id"], name: "user_role_fk_idx"
  end

  add_foreign_key "client_identifiers", "client_identifier_types", primary_key: "client_identifier_type_id", name: "client_identifiers_type_fk"
  add_foreign_key "client_identifiers", "clients", primary_key: "client_id", name: "client_identifier_client_fk"
  add_foreign_key "client_order_print_trails", "orders", primary_key: "order_id", name: "client_order_print_trail_order_fk"
  add_foreign_key "clients", "person", primary_key: "person_id", name: "client_person_fk"
  add_foreign_key "culture_observations", "tests", primary_key: "test_id", name: "culture_observations_test_fk"
  add_foreign_key "drug_organism_mapping", "drugs", primary_key: "drug_id", name: "drug_organism_mapping_drug_fk"
  add_foreign_key "drug_organism_mapping", "organisms", primary_key: "organism_id", name: "drug_organism_mapping_organism_fk"
  add_foreign_key "drug_susceptibility_test_results", "drugs", primary_key: "drug_id", name: "drug_susceptibility_test_result_drug_fk"
  add_foreign_key "drug_susceptibility_test_results", "organisms", primary_key: "organism_id", name: "drug_susceptibility_test_result_organism_fk"
  add_foreign_key "drug_susceptibility_test_results", "tests", primary_key: "test_id", name: "drug_susceptibility_test_result_test_fk"
  add_foreign_key "encounters", "clients", primary_key: "client_id", name: "encounters_client_fk"
  add_foreign_key "encounters", "facilities", primary_key: "facility_id", name: "visit_facility_fk"
  add_foreign_key "encounters", "facility_sections", primary_key: "facility_section_id", name: "visit_facility_section_fk"
  add_foreign_key "instrument_test_type_mapping", "instruments", primary_key: "instrument_id", name: "instrument_test_type_mapping_instrument_id"
  add_foreign_key "instrument_test_type_mapping", "test_types", primary_key: "test_type_id", name: "instrument_test_type_mapping_test_type_fk"
  add_foreign_key "orders", "encounters", primary_key: "encounter_id", name: "encounter_order_fk"
  add_foreign_key "orders", "priorities", primary_key: "priority_id", name: "order_priority_fk"
  add_foreign_key "role_privilege_mapping", "privileges", primary_key: "privilege_id", name: "privilege_role_privilege_mapping_fk"
  add_foreign_key "role_privilege_mapping", "roles", primary_key: "role_id", name: "role_role_privilege_mapping_fk"
  add_foreign_key "specimen_test_type_mapping", "specimens", primary_key: "specimen_id", name: "specimen_test_type_maps_specimen_fk"
  add_foreign_key "specimen_test_type_mapping", "test_types", primary_key: "test_type_id", name: "specimen_test_type_maps_test_type_id"
  add_foreign_key "test_indicator_ranges", "test_indicators", primary_key: "test_indicator_id", name: "test_indicator_range_tst_indicaor_fk"
  add_foreign_key "test_indicators", "test_types", primary_key: "test_type_id", name: "test_indicators_test_type_fk"
  add_foreign_key "test_results", "test_indicators", primary_key: "test_indicator_id", name: "test_result_test_indicator_fk"
  add_foreign_key "test_results", "tests", primary_key: "test_id", name: "test_result_test_fk"
  add_foreign_key "test_statuses", "statuses", primary_key: "status_id", name: "test_statuses_status_fk"
  add_foreign_key "test_statuses", "test_status_reasons", column: "status_reason_id", primary_key: "test_status_reason_id", name: "test_statuses_reason_fk"
  add_foreign_key "test_statuses", "tests", primary_key: "test_id", name: "test_statuses_test_fk", on_update: :cascade, on_delete: :cascade
  add_foreign_key "test_type_panel_mapping", "test_panels", column: "test_pannel_id", primary_key: "test_panel_id", name: "test_type_panel_mapping_test_panel_fk"
  add_foreign_key "test_type_panel_mapping", "test_types", primary_key: "test_type_id", name: "test_type_panel_mapping_test_type_fk"
  add_foreign_key "test_types", "departments", primary_key: "department_id", name: "test_type_department_fk"
  add_foreign_key "tests", "orders", primary_key: "order_id", name: "test_order_fk"
  add_foreign_key "tests", "specimens", primary_key: "specimen_id", name: "test_specimen_fk", on_update: :cascade, on_delete: :cascade
  add_foreign_key "tests", "test_types", primary_key: "test_type_id", name: "test_test_types_fk"
  add_foreign_key "user_department_mapping", "departments", primary_key: "department_id", name: "user_department"
  add_foreign_key "user_department_mapping", "users", primary_key: "user_id", name: "department_user_fk"
  add_foreign_key "users", "person", primary_key: "person_id", name: "user_person_fk"
  add_foreign_key "users", "roles", primary_key: "role_id", name: "user_role_fk"
end
