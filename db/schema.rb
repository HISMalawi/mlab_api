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

ActiveRecord::Schema[7.0].define(version: 2023_02_08_125954) do
  create_table "client_identifier_types", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "name"
    t.integer "retired"
    t.string "retired_reason"
    t.datetime "retired_date"
    t.datetime "created_date"
    t.datetime "updated_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "retired_by_id"
    t.bigint "creator_id", null: false
    t.index ["creator_id"], name: "index_client_identifier_types_on_creator_id"
    t.index ["retired_by_id"], name: "index_client_identifier_types_on_retired_by_id"
  end

  create_table "client_identifiers", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "client_identifier_type_id", null: false
    t.string "value"
    t.bigint "client_id", null: false
    t.integer "voided"
    t.string "voided_reason"
    t.datetime "voided_date"
    t.datetime "created_date"
    t.bigint "updated_date"
    t.string "uuid"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "voided_by_id"
    t.bigint "creator_id", null: false
    t.index ["client_id"], name: "index_client_identifiers_on_client_id"
    t.index ["client_identifier_type_id"], name: "index_client_identifiers_on_client_identifier_type_id"
    t.index ["creator_id"], name: "index_client_identifiers_on_creator_id"
    t.index ["voided_by_id"], name: "index_client_identifiers_on_voided_by_id"
  end

  create_table "client_order_print_trails", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "order_id", null: false
    t.integer "voided"
    t.string "voided_reason"
    t.datetime "voided_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "voided_by_id"
    t.bigint "creator_id", null: false
    t.index ["creator_id"], name: "index_client_order_print_trails_on_creator_id"
    t.index ["order_id"], name: "index_client_order_print_trails_on_order_id"
    t.index ["voided_by_id"], name: "index_client_order_print_trails_on_voided_by_id"
  end

  create_table "clients", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "person_id", null: false
    t.binary "uuid"
    t.integer "voided"
    t.string "voided_reason"
    t.datetime "voided_date"
    t.datetime "created_date"
    t.bigint "updated_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "voided_by_id"
    t.bigint "creator_id", null: false
    t.index ["creator_id"], name: "index_clients_on_creator_id"
    t.index ["person_id"], name: "index_clients_on_person_id"
    t.index ["voided_by_id"], name: "index_clients_on_voided_by_id"
  end

  create_table "culture_observations", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "test_id", null: false
    t.text "description"
    t.datetime "observation_datetime"
    t.integer "voided"
    t.string "voided_reason"
    t.datetime "voided_date"
    t.datetime "created_date"
    t.datetime "updated_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "voided_by_id"
    t.bigint "creator_id", null: false
    t.index ["creator_id"], name: "index_culture_observations_on_creator_id"
    t.index ["test_id"], name: "index_culture_observations_on_test_id"
    t.index ["voided_by_id"], name: "index_culture_observations_on_voided_by_id"
  end

  create_table "departments", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "name"
    t.integer "retired"
    t.string "retired_reason"
    t.datetime "retired_date"
    t.datetime "updated_date"
    t.datetime "created_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "retired_by_id"
    t.bigint "creator_id", null: false
    t.index ["creator_id"], name: "index_departments_on_creator_id"
    t.index ["retired_by_id"], name: "index_departments_on_retired_by_id"
  end

  create_table "drug_organism_mappings", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "drug_id", null: false
    t.bigint "organism_id", null: false
    t.integer "retired"
    t.string "retired_reason"
    t.datetime "retired_date"
    t.datetime "updated_date"
    t.datetime "created_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "retired_by_id"
    t.bigint "creator_id", null: false
    t.index ["creator_id"], name: "index_drug_organism_mappings_on_creator_id"
    t.index ["drug_id"], name: "index_drug_organism_mappings_on_drug_id"
    t.index ["organism_id"], name: "index_drug_organism_mappings_on_organism_id"
    t.index ["retired_by_id"], name: "index_drug_organism_mappings_on_retired_by_id"
  end

  create_table "drugs", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "short_name"
    t.string "name"
    t.integer "retired"
    t.string "retired_reason"
    t.datetime "retired_date"
    t.datetime "updated_date"
    t.datetime "created_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "retired_by_id"
    t.bigint "creator_id", null: false
    t.index ["creator_id"], name: "index_drugs_on_creator_id"
    t.index ["retired_by_id"], name: "index_drugs_on_retired_by_id"
  end

  create_table "encounters", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "client_id", null: false
    t.bigint "facility_id", null: false
    t.bigint "facility_section_id", null: false
    t.datetime "start_date"
    t.datetime "end_date"
    t.integer "voided"
    t.string "voided_reason"
    t.datetime "voided_date"
    t.datetime "created_date"
    t.datetime "updated_date"
    t.string "uuid"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "voided_by_id"
    t.bigint "creator_id", null: false
    t.bigint "destination_id", null: false
    t.index ["client_id"], name: "index_encounters_on_client_id"
    t.index ["creator_id"], name: "index_encounters_on_creator_id"
    t.index ["destination_id"], name: "index_encounters_on_destination_id"
    t.index ["facility_id"], name: "index_encounters_on_facility_id"
    t.index ["facility_section_id"], name: "index_encounters_on_facility_section_id"
    t.index ["voided_by_id"], name: "index_encounters_on_voided_by_id"
  end

  create_table "facilities", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "name"
    t.integer "retired"
    t.string "retired_reason"
    t.datetime "retired_date"
    t.datetime "created_date"
    t.datetime "updated_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "retired_by_id"
    t.bigint "creator_id", null: false
    t.index ["creator_id"], name: "index_facilities_on_creator_id"
    t.index ["retired_by_id"], name: "index_facilities_on_retired_by_id"
  end

  create_table "facility_sections", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "name"
    t.integer "retired"
    t.string "retired_reason"
    t.datetime "retired_date"
    t.datetime "created_date"
    t.datetime "updated_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "retired_by_id"
    t.bigint "creator_id", null: false
    t.index ["creator_id"], name: "index_facility_sections_on_creator_id"
    t.index ["retired_by_id"], name: "index_facility_sections_on_retired_by_id"
  end

  create_table "instrument_test_type_mappings", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "instrument_id", null: false
    t.bigint "test_type_id", null: false
    t.integer "retired"
    t.string "retired_reason"
    t.datetime "retired_date"
    t.datetime "created_date"
    t.datetime "updated_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "retired_by_id"
    t.bigint "creator_id", null: false
    t.index ["creator_id"], name: "index_instrument_test_type_mappings_on_creator_id"
    t.index ["instrument_id"], name: "index_instrument_test_type_mappings_on_instrument_id"
    t.index ["retired_by_id"], name: "index_instrument_test_type_mappings_on_retired_by_id"
    t.index ["test_type_id"], name: "index_instrument_test_type_mappings_on_test_type_id"
  end

  create_table "instruments", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "name"
    t.string "description"
    t.string "ip_address"
    t.string "hostname"
    t.integer "retired"
    t.string "retired_reason"
    t.datetime "retired_date"
    t.datetime "created_date"
    t.datetime "updated_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "retired_by_id"
    t.bigint "creator_id", null: false
    t.index ["creator_id"], name: "index_instruments_on_creator_id"
    t.index ["retired_by_id"], name: "index_instruments_on_retired_by_id"
  end

  create_table "orders", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "encounter_id", null: false
    t.bigint "priority_id", null: false
    t.string "accession_number"
    t.string "tracking_number"
    t.string "requested_by"
    t.datetime "sample_collected_time"
    t.string "collected_by"
    t.integer "voided"
    t.string "voided_reason"
    t.datetime "voided_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "voided_by_id"
    t.bigint "creator_id", null: false
    t.index ["creator_id"], name: "index_orders_on_creator_id"
    t.index ["encounter_id"], name: "index_orders_on_encounter_id"
    t.index ["priority_id"], name: "index_orders_on_priority_id"
    t.index ["voided_by_id"], name: "index_orders_on_voided_by_id"
  end

  create_table "organisms", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "name"
    t.string "description"
    t.integer "retired"
    t.string "retired_reason"
    t.datetime "retired_date"
    t.datetime "updated_date"
    t.datetime "created_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "retired_by_id"
    t.bigint "creator_id", null: false
    t.index ["creator_id"], name: "index_organisms_on_creator_id"
    t.index ["retired_by_id"], name: "index_organisms_on_retired_by_id"
  end

  create_table "people", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "first_name"
    t.string "middle_name"
    t.string "last_name"
    t.string "sex"
    t.date "date_of_birth"
    t.integer "birth_date_estimated"
    t.integer "voided"
    t.string "voided_reason"
    t.datetime "voided_date"
    t.datetime "created_date"
    t.bigint "updated_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "voided_by_id"
    t.bigint "creator_id"
    t.index ["creator_id"], name: "index_people_on_creator_id"
    t.index ["voided_by_id"], name: "index_people_on_voided_by_id"
  end

  create_table "priorities", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "name"
    t.integer "retired"
    t.string "retired_reason"
    t.datetime "retired_date"
    t.datetime "updated_date"
    t.datetime "created_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "retired_by_id"
    t.bigint "creator_id", null: false
    t.index ["creator_id"], name: "index_priorities_on_creator_id"
    t.index ["retired_by_id"], name: "index_priorities_on_retired_by_id"
  end

  create_table "privileges", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "name"
    t.integer "retired"
    t.string "retired_reason"
    t.datetime "retired_date"
    t.datetime "updated_date"
    t.datetime "created_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "retired_by_id"
    t.bigint "creator_id", null: false
    t.index ["creator_id"], name: "index_privileges_on_creator_id"
    t.index ["retired_by_id"], name: "index_privileges_on_retired_by_id"
  end

  create_table "role_privilege_mappings", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "role_id", null: false
    t.bigint "privilege_id", null: false
    t.integer "voided"
    t.string "voided_reason"
    t.datetime "voided_date"
    t.datetime "created_date"
    t.bigint "updated_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "voided_by_id"
    t.bigint "creator_id", null: false
    t.index ["creator_id"], name: "index_role_privilege_mappings_on_creator_id"
    t.index ["privilege_id"], name: "index_role_privilege_mappings_on_privilege_id"
    t.index ["role_id"], name: "index_role_privilege_mappings_on_role_id"
    t.index ["voided_by_id"], name: "index_role_privilege_mappings_on_voided_by_id"
  end

  create_table "roles", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "name"
    t.integer "retired"
    t.string "retired_reason"
    t.datetime "retired_date"
    t.datetime "updated_date"
    t.datetime "created_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "retired_by_id"
    t.bigint "creator_id"
    t.index ["creator_id"], name: "index_roles_on_creator_id"
    t.index ["retired_by_id"], name: "index_roles_on_retired_by_id"
  end

  create_table "specimen", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "name"
    t.integer "retired"
    t.string "retired_reason"
    t.datetime "retired_date"
    t.datetime "created_date"
    t.datetime "updated_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "retired_by_id"
    t.bigint "creator_id", null: false
    t.index ["creator_id"], name: "index_specimen_on_creator_id"
    t.index ["retired_by_id"], name: "index_specimen_on_retired_by_id"
  end

  create_table "specimen_test_type_mappings", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "specimen_id", null: false
    t.bigint "test_type_id", null: false
    t.integer "retired"
    t.string "retired_reason"
    t.datetime "retired_date"
    t.datetime "updated_date"
    t.datetime "created_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "retired_by_id"
    t.bigint "creator_id", null: false
    t.index ["creator_id"], name: "index_specimen_test_type_mappings_on_creator_id"
    t.index ["retired_by_id"], name: "index_specimen_test_type_mappings_on_retired_by_id"
    t.index ["specimen_id"], name: "index_specimen_test_type_mappings_on_specimen_id"
    t.index ["test_type_id"], name: "index_specimen_test_type_mappings_on_test_type_id"
  end

  create_table "status_reasons", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "description"
    t.integer "retired"
    t.string "retired_reason"
    t.datetime "retired_date"
    t.datetime "updated_date"
    t.datetime "created_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "retired_by_id"
    t.bigint "creator_id", null: false
    t.index ["creator_id"], name: "index_status_reasons_on_creator_id"
    t.index ["retired_by_id"], name: "index_status_reasons_on_retired_by_id"
  end

  create_table "statuses", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "name"
    t.integer "retired"
    t.string "retired_reason"
    t.datetime "retired_date"
    t.datetime "updated_date"
    t.datetime "updated_date_copy1"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "retired_by_id"
    t.bigint "creator_id", null: false
    t.index ["creator_id"], name: "index_statuses_on_creator_id"
    t.index ["retired_by_id"], name: "index_statuses_on_retired_by_id"
  end

  create_table "test_indicator_ranges", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "test_indicator_id", null: false
    t.integer "min_age"
    t.integer "max_age"
    t.string "sex"
    t.bigint "lower_range"
    t.bigint "upper_range"
    t.string "interpretation"
    t.string "value"
    t.integer "retired"
    t.string "retired_reason"
    t.datetime "retired_date"
    t.datetime "created_date"
    t.datetime "updated_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "retired_by_id"
    t.bigint "creator_id", null: false
    t.index ["creator_id"], name: "index_test_indicator_ranges_on_creator_id"
    t.index ["retired_by_id"], name: "index_test_indicator_ranges_on_retired_by_id"
    t.index ["test_indicator_id"], name: "index_test_indicator_ranges_on_test_indicator_id"
  end

  create_table "test_indicators", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "name"
    t.bigint "test_type_id", null: false
    t.integer "test_indicator_type"
    t.string "unit"
    t.string "description"
    t.integer "retired"
    t.string "retired_reason"
    t.datetime "retired_date"
    t.datetime "created_date"
    t.datetime "updated_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "retired_by_id"
    t.bigint "creator_id", null: false
    t.index ["creator_id"], name: "index_test_indicators_on_creator_id"
    t.index ["retired_by_id"], name: "index_test_indicators_on_retired_by_id"
    t.index ["test_type_id"], name: "index_test_indicators_on_test_type_id"
  end

  create_table "test_panels", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "name"
    t.string "description"
    t.integer "retired"
    t.string "retired_reason"
    t.datetime "retired_date"
    t.datetime "updated_date"
    t.datetime "created_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "retired_by_id"
    t.bigint "creator_id", null: false
    t.index ["creator_id"], name: "index_test_panels_on_creator_id"
    t.index ["retired_by_id"], name: "index_test_panels_on_retired_by_id"
  end

  create_table "test_results", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "test_id", null: false
    t.bigint "test_indicator_id", null: false
    t.text "value"
    t.datetime "result_date"
    t.integer "voided"
    t.string "voided_reason"
    t.datetime "voided_date"
    t.datetime "created_date"
    t.datetime "updated_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "voided_by_id"
    t.bigint "creator_id", null: false
    t.index ["creator_id"], name: "index_test_results_on_creator_id"
    t.index ["test_id"], name: "index_test_results_on_test_id"
    t.index ["test_indicator_id"], name: "index_test_results_on_test_indicator_id"
    t.index ["voided_by_id"], name: "index_test_results_on_voided_by_id"
  end

  create_table "test_statuses", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "test_id", null: false
    t.bigint "status_id", null: false
    t.bigint "status_reason_id", null: false
    t.integer "voided"
    t.string "voided_reason"
    t.datetime "voided_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "voided_by_id"
    t.bigint "creator_id", null: false
    t.index ["creator_id"], name: "index_test_statuses_on_creator_id"
    t.index ["status_id"], name: "index_test_statuses_on_status_id"
    t.index ["status_reason_id"], name: "index_test_statuses_on_status_reason_id"
    t.index ["test_id"], name: "index_test_statuses_on_test_id"
    t.index ["voided_by_id"], name: "index_test_statuses_on_voided_by_id"
  end

  create_table "test_type_panel_mappings", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "test_type_id", null: false
    t.bigint "test_panel_id", null: false
    t.integer "voided"
    t.string "voided_reason"
    t.datetime "voided_date"
    t.datetime "created_date"
    t.datetime "updated_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "voided_by_id"
    t.bigint "creator_id", null: false
    t.index ["creator_id"], name: "index_test_type_panel_mappings_on_creator_id"
    t.index ["test_panel_id"], name: "index_test_type_panel_mappings_on_test_panel_id"
    t.index ["test_type_id"], name: "index_test_type_panel_mappings_on_test_type_id"
    t.index ["voided_by_id"], name: "index_test_type_panel_mappings_on_voided_by_id"
  end

  create_table "test_types", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "name"
    t.bigint "department_id", null: false
    t.decimal "expected_turn_around_time", precision: 10
    t.integer "retired"
    t.string "retired_reason"
    t.datetime "retired_date"
    t.datetime "updated_date"
    t.datetime "created_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "retired_by_id"
    t.bigint "creator_id", null: false
    t.index ["creator_id"], name: "index_test_types_on_creator_id"
    t.index ["department_id"], name: "index_test_types_on_department_id"
    t.index ["retired_by_id"], name: "index_test_types_on_retired_by_id"
  end

  create_table "tests", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "specimen_id", null: false
    t.bigint "order_id", null: false
    t.bigint "test_type_id", null: false
    t.integer "voided"
    t.string "voided_reason"
    t.datetime "voided_date"
    t.datetime "created_date"
    t.datetime "updated_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "voided_by_id"
    t.bigint "creator_id", null: false
    t.index ["creator_id"], name: "index_tests_on_creator_id"
    t.index ["order_id"], name: "index_tests_on_order_id"
    t.index ["specimen_id"], name: "index_tests_on_specimen_id"
    t.index ["test_type_id"], name: "index_tests_on_test_type_id"
    t.index ["voided_by_id"], name: "index_tests_on_voided_by_id"
  end

  create_table "user_department_mappings", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "department_id", null: false
    t.integer "retired"
    t.string "retired_reason"
    t.datetime "retired_date"
    t.datetime "updated_date"
    t.datetime "created_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "retired_by_id"
    t.bigint "creator_id", null: false
    t.index ["creator_id"], name: "index_user_department_mappings_on_creator_id"
    t.index ["department_id"], name: "index_user_department_mappings_on_department_id"
    t.index ["retired_by_id"], name: "index_user_department_mappings_on_retired_by_id"
    t.index ["user_id"], name: "index_user_department_mappings_on_user_id"
  end

  create_table "users", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "role_id", null: false
    t.bigint "person_id", null: false
    t.string "username"
    t.string "password"
    t.string "last_password_changed"
    t.integer "voided"
    t.string "voided_reason"
    t.datetime "voided_date"
    t.datetime "created_date"
    t.bigint "updated_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "voided_by_id"
    t.bigint "creator_id", null: false
    t.index ["creator_id"], name: "index_users_on_creator_id"
    t.index ["person_id"], name: "index_users_on_person_id"
    t.index ["role_id"], name: "index_users_on_role_id"
    t.index ["voided_by_id"], name: "index_users_on_voided_by_id"
  end

  add_foreign_key "client_identifier_types", "users", column: "creator_id"
  add_foreign_key "client_identifier_types", "users", column: "retired_by_id"
  add_foreign_key "client_identifiers", "client_identifier_types"
  add_foreign_key "client_identifiers", "clients"
  add_foreign_key "client_identifiers", "users", column: "creator_id"
  add_foreign_key "client_identifiers", "users", column: "voided_by_id"
  add_foreign_key "client_order_print_trails", "orders"
  add_foreign_key "client_order_print_trails", "users", column: "creator_id"
  add_foreign_key "client_order_print_trails", "users", column: "voided_by_id"
  add_foreign_key "clients", "people"
  add_foreign_key "clients", "users", column: "creator_id"
  add_foreign_key "clients", "users", column: "voided_by_id"
  add_foreign_key "culture_observations", "tests"
  add_foreign_key "culture_observations", "users", column: "creator_id"
  add_foreign_key "culture_observations", "users", column: "voided_by_id"
  add_foreign_key "departments", "users", column: "creator_id"
  add_foreign_key "departments", "users", column: "retired_by_id"
  add_foreign_key "drug_organism_mappings", "drugs"
  add_foreign_key "drug_organism_mappings", "organisms"
  add_foreign_key "drug_organism_mappings", "users", column: "creator_id"
  add_foreign_key "drug_organism_mappings", "users", column: "retired_by_id"
  add_foreign_key "drugs", "users", column: "creator_id"
  add_foreign_key "drugs", "users", column: "retired_by_id"
  add_foreign_key "encounters", "clients"
  add_foreign_key "encounters", "facilities"
  add_foreign_key "encounters", "facilities", column: "destination_id"
  add_foreign_key "encounters", "facility_sections"
  add_foreign_key "encounters", "users", column: "creator_id"
  add_foreign_key "encounters", "users", column: "voided_by_id"
  add_foreign_key "facilities", "users", column: "creator_id"
  add_foreign_key "facilities", "users", column: "retired_by_id"
  add_foreign_key "facility_sections", "users", column: "creator_id"
  add_foreign_key "facility_sections", "users", column: "retired_by_id"
  add_foreign_key "instrument_test_type_mappings", "instruments"
  add_foreign_key "instrument_test_type_mappings", "test_types"
  add_foreign_key "instrument_test_type_mappings", "users", column: "creator_id"
  add_foreign_key "instrument_test_type_mappings", "users", column: "retired_by_id"
  add_foreign_key "instruments", "users", column: "creator_id"
  add_foreign_key "instruments", "users", column: "retired_by_id"
  add_foreign_key "orders", "encounters"
  add_foreign_key "orders", "priorities"
  add_foreign_key "orders", "users", column: "creator_id"
  add_foreign_key "orders", "users", column: "voided_by_id"
  add_foreign_key "organisms", "users", column: "creator_id"
  add_foreign_key "organisms", "users", column: "retired_by_id"
  add_foreign_key "people", "users", column: "creator_id"
  add_foreign_key "people", "users", column: "voided_by_id"
  add_foreign_key "priorities", "users", column: "creator_id"
  add_foreign_key "priorities", "users", column: "retired_by_id"
  add_foreign_key "privileges", "users", column: "creator_id"
  add_foreign_key "privileges", "users", column: "retired_by_id"
  add_foreign_key "role_privilege_mappings", "privileges"
  add_foreign_key "role_privilege_mappings", "roles"
  add_foreign_key "role_privilege_mappings", "users", column: "creator_id"
  add_foreign_key "role_privilege_mappings", "users", column: "voided_by_id"
  add_foreign_key "roles", "users", column: "creator_id"
  add_foreign_key "roles", "users", column: "retired_by_id"
  add_foreign_key "specimen", "users", column: "creator_id"
  add_foreign_key "specimen", "users", column: "retired_by_id"
  add_foreign_key "specimen_test_type_mappings", "specimen", column: "specimen_id"
  add_foreign_key "specimen_test_type_mappings", "test_types"
  add_foreign_key "specimen_test_type_mappings", "users", column: "creator_id"
  add_foreign_key "specimen_test_type_mappings", "users", column: "retired_by_id"
  add_foreign_key "status_reasons", "users", column: "creator_id"
  add_foreign_key "status_reasons", "users", column: "retired_by_id"
  add_foreign_key "statuses", "users", column: "creator_id"
  add_foreign_key "statuses", "users", column: "retired_by_id"
  add_foreign_key "test_indicator_ranges", "test_indicators"
  add_foreign_key "test_indicator_ranges", "users", column: "creator_id"
  add_foreign_key "test_indicator_ranges", "users", column: "retired_by_id"
  add_foreign_key "test_indicators", "test_types"
  add_foreign_key "test_indicators", "users", column: "creator_id"
  add_foreign_key "test_indicators", "users", column: "retired_by_id"
  add_foreign_key "test_panels", "users", column: "creator_id"
  add_foreign_key "test_panels", "users", column: "retired_by_id"
  add_foreign_key "test_results", "test_indicators"
  add_foreign_key "test_results", "tests"
  add_foreign_key "test_results", "users", column: "creator_id"
  add_foreign_key "test_results", "users", column: "voided_by_id"
  add_foreign_key "test_statuses", "status_reasons"
  add_foreign_key "test_statuses", "statuses"
  add_foreign_key "test_statuses", "tests"
  add_foreign_key "test_statuses", "users", column: "creator_id"
  add_foreign_key "test_statuses", "users", column: "voided_by_id"
  add_foreign_key "test_type_panel_mappings", "test_panels"
  add_foreign_key "test_type_panel_mappings", "test_types"
  add_foreign_key "test_type_panel_mappings", "users", column: "creator_id"
  add_foreign_key "test_type_panel_mappings", "users", column: "voided_by_id"
  add_foreign_key "test_types", "departments"
  add_foreign_key "test_types", "users", column: "creator_id"
  add_foreign_key "test_types", "users", column: "retired_by_id"
  add_foreign_key "tests", "orders"
  add_foreign_key "tests", "specimen", column: "specimen_id"
  add_foreign_key "tests", "test_types"
  add_foreign_key "tests", "users", column: "creator_id"
  add_foreign_key "tests", "users", column: "voided_by_id"
  add_foreign_key "user_department_mappings", "departments"
  add_foreign_key "user_department_mappings", "users"
  add_foreign_key "user_department_mappings", "users", column: "creator_id"
  add_foreign_key "user_department_mappings", "users", column: "retired_by_id"
  add_foreign_key "users", "people"
  add_foreign_key "users", "roles"
  add_foreign_key "users", "users", column: "creator_id"
  add_foreign_key "users", "users", column: "voided_by_id"
end
