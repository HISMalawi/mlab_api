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

ActiveRecord::Schema[7.0].define(version: 2024_02_08_125959) do
  create_table "client_identifier_types", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "name"
    t.integer "retired"
    t.bigint "retired_by"
    t.string "retired_reason"
    t.datetime "retired_date"
    t.bigint "creator"
    t.datetime "created_date"
    t.datetime "updated_date"
    t.index ["creator"], name: "fk_rails_76d55355c3"
    t.index ["retired_by"], name: "fk_rails_19fcfd1174"
  end

  create_table "client_identifiers", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "client_identifier_type_id", null: false
    t.string "value"
    t.bigint "client_id", null: false
    t.integer "voided"
    t.bigint "voided_by"
    t.string "voided_reason"
    t.datetime "voided_date"
    t.bigint "creator"
    t.datetime "created_date"
    t.datetime "updated_date"
    t.index ["client_id"], name: "index_client_identifiers_on_client_id"
    t.index ["client_identifier_type_id"], name: "index_client_identifiers_on_client_identifier_type_id"
    t.index ["creator"], name: "fk_rails_1d6a18d6aa"
    t.index ["voided_by"], name: "fk_rails_77f50c4288"
  end

  create_table "client_order_print_trails", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "order_id", null: false
    t.bigint "creator"
    t.integer "voided"
    t.bigint "voided_by"
    t.string "voided_reason"
    t.datetime "voided_date"
    t.datetime "created_date"
    t.datetime "updated_date"
    t.index ["creator"], name: "fk_rails_f6852eeed6"
    t.index ["order_id"], name: "index_client_order_print_trails_on_order_id"
    t.index ["voided_by"], name: "fk_rails_d0e284cc0a"
  end

  create_table "clients", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "person_id", null: false
    t.binary "uuid"
    t.integer "voided"
    t.bigint "voided_by"
    t.string "voided_reason"
    t.datetime "voided_date"
    t.bigint "creator"
    t.datetime "created_date"
    t.datetime "updated_date"
    t.index ["creator"], name: "fk_rails_8bd1def1b3"
    t.index ["person_id"], name: "index_clients_on_person_id"
    t.index ["voided_by"], name: "fk_rails_8ddb993c38"
  end

  create_table "culture_observations", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "test_id", null: false
    t.text "description"
    t.datetime "observation_datetime"
    t.integer "voided"
    t.bigint "voided_by"
    t.string "voided_reason"
    t.datetime "voided_date"
    t.bigint "creator"
    t.datetime "created_date"
    t.datetime "updated_date"
    t.index ["creator"], name: "fk_rails_336ba6c926"
    t.index ["test_id"], name: "index_culture_observations_on_test_id"
    t.index ["voided_by"], name: "fk_rails_71c231eae4"
  end

  create_table "departments", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "name"
    t.integer "retired"
    t.bigint "retired_by"
    t.string "retired_reason"
    t.datetime "retired_date"
    t.bigint "creator"
    t.datetime "updated_date"
    t.datetime "created_date"
    t.index ["creator"], name: "fk_rails_7aef731b14"
    t.index ["retired_by"], name: "fk_rails_07e4d2e8c0"
  end

  create_table "diseases", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "name", null: false
    t.integer "voided", default: 0
    t.bigint "voided_by"
    t.string "voided_reason"
    t.datetime "voided_date"
    t.bigint "creator", null: false
    t.datetime "created_date", null: false
    t.datetime "updated_date", null: false
    t.index ["creator"], name: "fk_rails_28375b9bab"
    t.index ["voided_by"], name: "fk_rails_171f5ed44e"
  end

  create_table "drug_organism_mappings", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "drug_id", null: false
    t.bigint "organism_id", null: false
    t.integer "retired"
    t.bigint "retired_by"
    t.string "retired_reason"
    t.datetime "retired_date"
    t.bigint "creator"
    t.datetime "updated_date"
    t.datetime "created_date"
    t.index ["creator"], name: "fk_rails_0800e412cf"
    t.index ["drug_id"], name: "index_drug_organism_mappings_on_drug_id"
    t.index ["organism_id"], name: "index_drug_organism_mappings_on_organism_id"
    t.index ["retired_by"], name: "fk_rails_9129054208"
  end

  create_table "drug_susceptibilities", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "test_id"
    t.bigint "organism_id"
    t.bigint "drug_id"
    t.string "zone"
    t.string "interpretation"
    t.integer "voided"
    t.bigint "voided_by"
    t.string "voided_reason"
    t.datetime "voided_date"
    t.bigint "creator"
    t.datetime "created_date"
    t.datetime "updated_date"
    t.bigint "updated_by"
    t.index ["creator"], name: "fk_rails_abbf6ef5f4"
    t.index ["drug_id"], name: "index_drug_susceptibilities_on_drug_id"
    t.index ["organism_id"], name: "index_drug_susceptibilities_on_organism_id"
    t.index ["test_id"], name: "index_drug_susceptibilities_on_test_id"
    t.index ["updated_by"], name: "fk_rails_eccdf633c6"
    t.index ["voided_by"], name: "fk_rails_7531bd17a0"
  end

  create_table "drugs", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "short_name"
    t.string "name"
    t.integer "retired"
    t.bigint "retired_by"
    t.string "retired_reason"
    t.datetime "retired_date"
    t.bigint "creator"
    t.datetime "updated_date"
    t.datetime "created_date"
    t.index ["creator"], name: "fk_rails_f659be91a8"
    t.index ["retired_by"], name: "fk_rails_6c278e75fd"
  end

  create_table "encounter_type_facility_section_mappings", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "creator"
    t.integer "voided"
    t.bigint "voided_by"
    t.string "voided_reason"
    t.datetime "voided_date"
    t.datetime "created_date"
    t.datetime "updated_date"
    t.bigint "facility_section_id", null: false
    t.bigint "encounter_type_id", null: false
    t.index ["creator"], name: "fk_rails_0a2ba9e596"
    t.index ["encounter_type_id"], name: "fk_rails_2880469aa4"
    t.index ["facility_section_id"], name: "fk_rails_afdb26e1db"
    t.index ["voided_by"], name: "fk_rails_f4b4388678"
  end

  create_table "encounter_types", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "name"
    t.string "description"
    t.bigint "creator"
    t.integer "voided"
    t.bigint "voided_by"
    t.string "voided_reason"
    t.datetime "voided_date"
    t.datetime "created_date"
    t.datetime "updated_date"
    t.index ["creator"], name: "fk_rails_c085b6c147"
    t.index ["voided_by"], name: "fk_rails_3b11e06173"
  end

  create_table "encounters", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "client_id", null: false
    t.bigint "facility_id", null: false
    t.bigint "destination_id", null: false
    t.bigint "facility_section_id", null: false
    t.datetime "start_date"
    t.datetime "end_date"
    t.integer "voided"
    t.bigint "voided_by"
    t.string "voided_reason"
    t.datetime "voided_date"
    t.bigint "creator"
    t.datetime "created_date"
    t.datetime "updated_date"
    t.string "uuid"
    t.bigint "encounter_type_id"
    t.index ["client_id"], name: "index_encounters_on_client_id"
    t.index ["creator"], name: "fk_rails_d942b30673"
    t.index ["destination_id"], name: "index_encounters_on_destination_id"
    t.index ["encounter_type_id"], name: "fk_rails_cf33a2decd"
    t.index ["facility_id"], name: "index_encounters_on_facility_id"
    t.index ["facility_section_id"], name: "index_encounters_on_facility_section_id"
    t.index ["voided_by"], name: "fk_rails_bd2826d55e"
  end

  create_table "facilities", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "name"
    t.integer "retired"
    t.bigint "retired_by"
    t.string "retired_reason"
    t.datetime "retired_date"
    t.bigint "creator"
    t.datetime "created_date"
    t.datetime "updated_date"
    t.index ["creator"], name: "fk_rails_d28145efac"
    t.index ["retired_by"], name: "fk_rails_e319067bf9"
  end

  create_table "facility_sections", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "name"
    t.integer "retired"
    t.bigint "retired_by"
    t.string "retired_reason"
    t.datetime "retired_date"
    t.bigint "creator"
    t.datetime "created_date"
    t.datetime "updated_date"
    t.index ["creator"], name: "fk_rails_72da1deecd"
    t.index ["retired_by"], name: "fk_rails_2b632c0b11"
  end

  create_table "globals", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "name"
    t.string "code"
    t.string "address"
    t.string "phone"
    t.bigint "creator"
    t.integer "retired"
    t.bigint "retired_by"
    t.string "retired_reason"
    t.datetime "retired_date"
    t.datetime "created_date"
    t.datetime "updated_date"
    t.index ["creator"], name: "fk_rails_bb30e1b9e2"
    t.index ["retired_by"], name: "fk_rails_57610fb0a4"
  end

  create_table "instrument_test_type_mappings", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "instrument_id", null: false
    t.bigint "test_type_id", null: false
    t.integer "retired"
    t.bigint "retired_by"
    t.string "retired_reason"
    t.datetime "retired_date"
    t.bigint "creator"
    t.datetime "created_date"
    t.datetime "updated_date"
    t.index ["creator"], name: "fk_rails_d97721fc8d"
    t.index ["instrument_id"], name: "index_instrument_test_type_mappings_on_instrument_id"
    t.index ["retired_by"], name: "fk_rails_051201364f"
    t.index ["test_type_id"], name: "index_instrument_test_type_mappings_on_test_type_id"
  end

  create_table "instruments", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "name"
    t.string "description"
    t.string "ip_address"
    t.string "hostname"
    t.integer "retired"
    t.bigint "retired_by"
    t.string "retired_reason"
    t.datetime "retired_date"
    t.bigint "creator"
    t.datetime "created_date"
    t.datetime "updated_date"
    t.index ["creator"], name: "fk_rails_31d4d000b3"
    t.index ["retired_by"], name: "fk_rails_b85ba53bf5"
  end

  create_table "order_statuses", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "order_id", null: false
    t.bigint "status_id", null: false
    t.bigint "status_reason_id", null: false
    t.bigint "creator", null: false
    t.integer "voided", default: 0
    t.bigint "voided_by"
    t.string "voided_reason"
    t.datetime "voided_date"
    t.datetime "created_date", null: false
    t.datetime "updated_date", null: false
    t.index ["creator"], name: "fk_rails_0510d94594"
    t.index ["order_id"], name: "index_order_statuses_on_order_id"
    t.index ["status_id"], name: "index_order_statuses_on_status_id"
    t.index ["status_reason_id"], name: "index_order_statuses_on_status_reason_id"
    t.index ["voided_by"], name: "fk_rails_8d4fff77b7"
  end

  create_table "orders", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "encounter_id", null: false
    t.bigint "priority_id", null: false
    t.string "accession_number"
    t.string "tracking_number"
    t.string "requested_by"
    t.datetime "sample_collected_time"
    t.string "collected_by"
    t.bigint "creator"
    t.integer "voided"
    t.bigint "voided_by"
    t.string "voided_reason"
    t.datetime "voided_date"
    t.datetime "created_date"
    t.datetime "updated_date"
    t.index ["creator"], name: "fk_rails_58c783a090"
    t.index ["encounter_id"], name: "index_orders_on_encounter_id"
    t.index ["priority_id"], name: "index_orders_on_priority_id"
    t.index ["voided_by"], name: "fk_rails_6891831a3d"
  end

  create_table "organisms", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "name"
    t.string "description"
    t.integer "retired"
    t.bigint "retired_by"
    t.string "retired_reason"
    t.datetime "retired_date"
    t.bigint "creator"
    t.datetime "updated_date"
    t.datetime "created_date"
    t.index ["creator"], name: "fk_rails_112492a36b"
    t.index ["retired_by"], name: "fk_rails_0ca4fdfa97"
  end

  create_table "people", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "first_name"
    t.string "middle_name"
    t.string "last_name"
    t.string "sex"
    t.date "date_of_birth"
    t.boolean "birth_date_estimated"
    t.integer "voided"
    t.bigint "voided_by"
    t.string "voided_reason"
    t.datetime "voided_date"
    t.bigint "creator"
    t.datetime "created_date"
    t.datetime "updated_date"
    t.index ["creator"], name: "fk_rails_4a9413ff3e"
    t.index ["voided_by"], name: "fk_rails_a6e182138c"
  end

  create_table "priorities", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "name"
    t.integer "retired"
    t.bigint "retired_by"
    t.string "retired_reason"
    t.datetime "retired_date"
    t.bigint "creator"
    t.datetime "updated_date"
    t.datetime "created_date"
    t.index ["creator"], name: "fk_rails_555d2a3bd5"
    t.index ["retired_by"], name: "fk_rails_b0bb8c2a6e"
  end

  create_table "privileges", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "name"
    t.string "display_name"
    t.integer "retired"
    t.bigint "retired_by"
    t.string "retired_reason"
    t.datetime "retired_date"
    t.bigint "creator"
    t.datetime "updated_date"
    t.datetime "created_date"
    t.index ["creator"], name: "fk_rails_13b25d4d99"
    t.index ["retired_by"], name: "fk_rails_74d4b13f40"
  end

  create_table "role_privilege_mappings", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "role_id", null: false
    t.bigint "privilege_id", null: false
    t.integer "voided"
    t.bigint "voided_by"
    t.string "voided_reason"
    t.datetime "voided_date"
    t.bigint "creator"
    t.datetime "created_date"
    t.datetime "updated_date"
    t.index ["creator"], name: "fk_rails_d72d795e2e"
    t.index ["privilege_id"], name: "index_role_privilege_mappings_on_privilege_id"
    t.index ["role_id"], name: "index_role_privilege_mappings_on_role_id"
    t.index ["voided_by"], name: "fk_rails_c02b7ac72f"
  end

  create_table "roles", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "name"
    t.integer "retired"
    t.bigint "retired_by"
    t.string "retired_reason"
    t.datetime "retired_date"
    t.bigint "creator"
    t.datetime "updated_date"
    t.datetime "created_date"
    t.index ["creator"], name: "fk_rails_f0b260e680"
    t.index ["retired_by"], name: "fk_rails_aa96010497"
  end

  create_table "specimen", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "name"
    t.string "description"
    t.integer "retired"
    t.bigint "retired_by"
    t.string "retired_reason"
    t.datetime "retired_date"
    t.bigint "creator"
    t.datetime "created_date"
    t.datetime "updated_date"
    t.index ["creator"], name: "fk_rails_3d6fc047ad"
    t.index ["retired_by"], name: "fk_rails_10ee122152"
  end

  create_table "specimen_test_type_mappings", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "specimen_id", null: false
    t.bigint "test_type_id", null: false
    t.integer "life_span"
    t.column "life_span_units", "enum('mins','hours','days','months')"
    t.integer "retired"
    t.bigint "retired_by"
    t.string "retired_reason"
    t.datetime "retired_date"
    t.bigint "creator"
    t.datetime "updated_date"
    t.datetime "created_date"
    t.index ["creator"], name: "fk_rails_c40492fbeb"
    t.index ["retired_by"], name: "fk_rails_47458cb1ed"
    t.index ["specimen_id"], name: "index_specimen_test_type_mappings_on_specimen_id"
    t.index ["test_type_id"], name: "index_specimen_test_type_mappings_on_test_type_id"
  end

  create_table "status_reasons", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.text "description"
    t.integer "retired"
    t.bigint "retired_by"
    t.string "retired_reason"
    t.datetime "retired_date"
    t.bigint "creator"
    t.datetime "updated_date"
    t.datetime "created_date"
    t.index ["creator"], name: "fk_rails_a051adf67c"
    t.index ["retired_by"], name: "fk_rails_7181c23722"
  end

  create_table "statuses", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "name"
    t.integer "retired"
    t.bigint "retired_by"
    t.string "retired_reason"
    t.datetime "retired_date"
    t.bigint "creator"
    t.datetime "created_date"
    t.datetime "updated_date"
    t.index ["creator"], name: "fk_rails_03b122d8ec"
    t.index ["retired_by"], name: "fk_rails_dc1b2e5f4a"
  end

  create_table "surveillances", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "test_types_id"
    t.bigint "diseases_id"
    t.integer "voided", default: 0
    t.bigint "voided_by"
    t.string "voided_reason"
    t.datetime "voided_date"
    t.bigint "creator", null: false
    t.datetime "created_date", null: false
    t.datetime "updated_date", null: false
    t.index ["creator"], name: "fk_rails_66eb7c6a50"
    t.index ["diseases_id"], name: "index_surveillances_on_diseases_id"
    t.index ["test_types_id"], name: "index_surveillances_on_test_types_id"
    t.index ["voided_by"], name: "fk_rails_94adfec205"
  end

  create_table "test_indicator_ranges", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "test_indicator_id", null: false
    t.integer "min_age"
    t.integer "max_age"
    t.string "sex"
    t.decimal "lower_range", precision: 65, scale: 4
    t.decimal "upper_range", precision: 65, scale: 4
    t.string "interpretation"
    t.string "value"
    t.integer "retired"
    t.bigint "retired_by"
    t.string "retired_reason"
    t.datetime "retired_date"
    t.bigint "creator"
    t.datetime "created_date"
    t.datetime "updated_date"
    t.index ["creator"], name: "fk_rails_822a0e09d9"
    t.index ["retired_by"], name: "fk_rails_c7a13cd42e"
    t.index ["test_indicator_id"], name: "index_test_indicator_ranges_on_test_indicator_id"
  end

  create_table "test_indicators", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "name"
    t.bigint "test_type_id", null: false
    t.integer "test_indicator_type"
    t.string "unit"
    t.string "description"
    t.integer "retired"
    t.bigint "retired_by"
    t.string "retired_reason"
    t.datetime "retired_date"
    t.bigint "creator"
    t.datetime "created_date"
    t.datetime "updated_date"
    t.index ["creator"], name: "fk_rails_fda346a95f"
    t.index ["retired_by"], name: "fk_rails_8fea8a0952"
    t.index ["test_type_id"], name: "index_test_indicators_on_test_type_id"
  end

  create_table "test_panels", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "name"
    t.string "short_name"
    t.string "description"
    t.integer "retired"
    t.bigint "retired_by"
    t.string "retired_reason"
    t.datetime "retired_date"
    t.bigint "creator"
    t.datetime "updated_date"
    t.datetime "created_date"
    t.index ["creator"], name: "fk_rails_f9cb5cd94a"
    t.index ["retired_by"], name: "fk_rails_37372fa1a2"
  end

  create_table "test_results", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "test_id", null: false
    t.bigint "test_indicator_id", null: false
    t.text "value"
    t.datetime "result_date"
    t.integer "voided"
    t.bigint "voided_by"
    t.string "voided_reason"
    t.datetime "voided_date"
    t.bigint "creator"
    t.datetime "created_date"
    t.datetime "updated_date"
    t.index ["creator"], name: "fk_rails_e31692d4ca"
    t.index ["test_id"], name: "index_test_results_on_test_id"
    t.index ["test_indicator_id"], name: "index_test_results_on_test_indicator_id"
    t.index ["voided_by"], name: "fk_rails_d60aefd51e"
  end

  create_table "test_statuses", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "test_id", null: false
    t.bigint "status_id", null: false
    t.bigint "status_reason_id"
    t.bigint "creator"
    t.integer "voided"
    t.bigint "voided_by"
    t.string "voided_reason"
    t.datetime "voided_date"
    t.datetime "created_date"
    t.datetime "updated_date"
    t.index ["creator"], name: "fk_rails_0adac8ee6b"
    t.index ["status_id"], name: "index_test_statuses_on_status_id"
    t.index ["status_reason_id"], name: "index_test_statuses_on_status_reason_id"
    t.index ["test_id"], name: "index_test_statuses_on_test_id"
    t.index ["voided_by"], name: "fk_rails_f6510b76c0"
  end

  create_table "test_type_organism_mappings", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "test_type_id", null: false
    t.bigint "organism_id", null: false
    t.bigint "creator"
    t.integer "retired"
    t.bigint "retired_by"
    t.string "retired_reason"
    t.datetime "retired_date"
    t.datetime "updated_date"
    t.datetime "created_date"
    t.index ["creator"], name: "fk_rails_30264e8cf9"
    t.index ["organism_id"], name: "index_test_type_organism_mappings_on_organism_id"
    t.index ["retired_by"], name: "fk_rails_eb65b8696d"
    t.index ["test_type_id"], name: "index_test_type_organism_mappings_on_test_type_id"
  end

  create_table "test_type_panel_mappings", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "test_type_id", null: false
    t.bigint "test_panel_id", null: false
    t.integer "voided"
    t.bigint "voided_by"
    t.string "voided_reason"
    t.datetime "voided_date"
    t.bigint "creator"
    t.datetime "created_date"
    t.datetime "updated_date"
    t.index ["creator"], name: "fk_rails_3c1b4cdb96"
    t.index ["test_panel_id"], name: "index_test_type_panel_mappings_on_test_panel_id"
    t.index ["test_type_id"], name: "index_test_type_panel_mappings_on_test_type_id"
    t.index ["voided_by"], name: "fk_rails_83dfe97307"
  end

  create_table "test_types", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "name"
    t.string "short_name"
    t.bigint "department_id", null: false
    t.decimal "expected_turn_around_time", precision: 65, scale: 2
    t.integer "retired"
    t.bigint "retired_by"
    t.string "retired_reason"
    t.datetime "retired_date"
    t.bigint "creator"
    t.datetime "updated_date"
    t.datetime "created_date"
    t.index ["creator"], name: "fk_rails_fc31efdaf6"
    t.index ["department_id"], name: "index_test_types_on_department_id"
    t.index ["retired_by"], name: "fk_rails_e098721114"
  end

  create_table "tests", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "specimen_id", null: false
    t.bigint "order_id", null: false
    t.bigint "test_type_id", null: false
    t.bigint "test_panel_id"
    t.integer "voided"
    t.bigint "voided_by"
    t.string "voided_reason"
    t.datetime "voided_date"
    t.bigint "creator"
    t.datetime "created_date"
    t.datetime "updated_date"
    t.index ["creator"], name: "fk_rails_9e21c12cab"
    t.index ["order_id"], name: "index_tests_on_order_id"
    t.index ["specimen_id"], name: "index_tests_on_specimen_id"
    t.index ["test_panel_id"], name: "index_tests_on_test_panel_id"
    t.index ["test_type_id"], name: "index_tests_on_test_type_id"
    t.index ["voided_by"], name: "fk_rails_1c50d4e771"
  end

  create_table "user_department_mappings", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "department_id", null: false
    t.integer "retired"
    t.bigint "retired_by"
    t.string "retired_reason"
    t.datetime "retired_date"
    t.bigint "creator"
    t.datetime "updated_date"
    t.datetime "created_date"
    t.index ["creator"], name: "fk_rails_749595bdf9"
    t.index ["department_id"], name: "index_user_department_mappings_on_department_id"
    t.index ["retired_by"], name: "fk_rails_700d5dc05d"
    t.index ["user_id"], name: "index_user_department_mappings_on_user_id"
  end

  create_table "user_role_mappings", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "role_id", null: false
    t.integer "retired"
    t.bigint "retired_by"
    t.string "retired_reason"
    t.datetime "retired_date"
    t.bigint "creator"
    t.datetime "updated_date"
    t.datetime "created_date"
    t.index ["creator"], name: "fk_rails_70a7a9087a"
    t.index ["retired_by"], name: "fk_rails_7009c0ebef"
    t.index ["role_id"], name: "index_user_role_mappings_on_role_id"
    t.index ["user_id"], name: "index_user_role_mappings_on_user_id"
  end

  create_table "users", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "person_id", null: false
    t.string "username"
    t.string "password"
    t.datetime "last_password_changed"
    t.integer "voided"
    t.bigint "voided_by"
    t.string "voided_reason"
    t.datetime "voided_date"
    t.bigint "creator"
    t.datetime "created_date"
    t.datetime "updated_date"
    t.integer "is_active"
    t.index ["creator"], name: "fk_rails_fd256d8564"
    t.index ["person_id"], name: "index_users_on_person_id"
    t.index ["voided_by"], name: "fk_rails_10e8c3ab59"
  end

  create_table "visit_type_facility_section_mappings", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.integer "retired"
    t.bigint "retired_by"
    t.string "retired_reason"
    t.datetime "retired_date"
    t.bigint "creator"
    t.datetime "updated_date"
    t.datetime "created_date"
    t.bigint "facility_section_id", null: false
    t.bigint "visit_type_id", null: false
    t.index ["creator"], name: "fk_rails_7fc43c315a"
    t.index ["facility_section_id"], name: "fk_rails_79cf966fd7"
    t.index ["retired_by"], name: "fk_rails_663642c7d8"
    t.index ["visit_type_id"], name: "fk_rails_607bb2a066"
  end

  create_table "visit_types", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "name"
    t.integer "retired"
    t.bigint "retired_by"
    t.string "retired_reason"
    t.datetime "retired_date"
    t.bigint "creator"
    t.datetime "created_date"
    t.datetime "updated_date"
    t.index ["creator"], name: "fk_rails_8098698b0f"
    t.index ["retired_by"], name: "fk_rails_c55e7d0885"
  end

  add_foreign_key "client_identifier_types", "users", column: "creator"
  add_foreign_key "client_identifier_types", "users", column: "retired_by"
  add_foreign_key "client_identifiers", "client_identifier_types"
  add_foreign_key "client_identifiers", "clients"
  add_foreign_key "client_identifiers", "users", column: "creator"
  add_foreign_key "client_identifiers", "users", column: "voided_by"
  add_foreign_key "client_order_print_trails", "orders"
  add_foreign_key "client_order_print_trails", "users", column: "creator"
  add_foreign_key "client_order_print_trails", "users", column: "voided_by"
  add_foreign_key "clients", "people"
  add_foreign_key "clients", "users", column: "creator"
  add_foreign_key "clients", "users", column: "voided_by"
  add_foreign_key "culture_observations", "tests"
  add_foreign_key "culture_observations", "users", column: "creator"
  add_foreign_key "culture_observations", "users", column: "voided_by"
  add_foreign_key "departments", "users", column: "creator"
  add_foreign_key "departments", "users", column: "retired_by"
  add_foreign_key "diseases", "users", column: "creator"
  add_foreign_key "diseases", "users", column: "voided_by"
  add_foreign_key "drug_organism_mappings", "drugs"
  add_foreign_key "drug_organism_mappings", "organisms"
  add_foreign_key "drug_organism_mappings", "users", column: "creator"
  add_foreign_key "drug_organism_mappings", "users", column: "retired_by"
  add_foreign_key "drug_susceptibilities", "drugs"
  add_foreign_key "drug_susceptibilities", "organisms"
  add_foreign_key "drug_susceptibilities", "tests"
  add_foreign_key "drug_susceptibilities", "users", column: "creator"
  add_foreign_key "drug_susceptibilities", "users", column: "updated_by"
  add_foreign_key "drug_susceptibilities", "users", column: "voided_by"
  add_foreign_key "drugs", "users", column: "creator"
  add_foreign_key "drugs", "users", column: "retired_by"
  add_foreign_key "encounter_type_facility_section_mappings", "encounter_types"
  add_foreign_key "encounter_type_facility_section_mappings", "facility_sections"
  add_foreign_key "encounter_type_facility_section_mappings", "users", column: "creator"
  add_foreign_key "encounter_type_facility_section_mappings", "users", column: "voided_by"
  add_foreign_key "encounter_types", "users", column: "creator"
  add_foreign_key "encounter_types", "users", column: "voided_by"
  add_foreign_key "encounters", "clients"
  add_foreign_key "encounters", "encounter_types"
  add_foreign_key "encounters", "facilities"
  add_foreign_key "encounters", "facilities", column: "destination_id"
  add_foreign_key "encounters", "facility_sections"
  add_foreign_key "encounters", "users", column: "creator"
  add_foreign_key "encounters", "users", column: "voided_by"
  add_foreign_key "facilities", "users", column: "creator"
  add_foreign_key "facilities", "users", column: "retired_by"
  add_foreign_key "facility_sections", "users", column: "creator"
  add_foreign_key "facility_sections", "users", column: "retired_by"
  add_foreign_key "globals", "users", column: "creator"
  add_foreign_key "globals", "users", column: "retired_by"
  add_foreign_key "instrument_test_type_mappings", "instruments"
  add_foreign_key "instrument_test_type_mappings", "test_types"
  add_foreign_key "instrument_test_type_mappings", "users", column: "creator"
  add_foreign_key "instrument_test_type_mappings", "users", column: "retired_by"
  add_foreign_key "instruments", "users", column: "creator"
  add_foreign_key "instruments", "users", column: "retired_by"
  add_foreign_key "order_statuses", "orders"
  add_foreign_key "order_statuses", "status_reasons"
  add_foreign_key "order_statuses", "statuses"
  add_foreign_key "order_statuses", "users", column: "creator"
  add_foreign_key "order_statuses", "users", column: "voided_by"
  add_foreign_key "orders", "encounters"
  add_foreign_key "orders", "priorities"
  add_foreign_key "orders", "users", column: "creator"
  add_foreign_key "orders", "users", column: "voided_by"
  add_foreign_key "organisms", "users", column: "creator"
  add_foreign_key "organisms", "users", column: "retired_by"
  add_foreign_key "people", "users", column: "creator"
  add_foreign_key "people", "users", column: "voided_by"
  add_foreign_key "priorities", "users", column: "creator"
  add_foreign_key "priorities", "users", column: "retired_by"
  add_foreign_key "privileges", "users", column: "creator"
  add_foreign_key "privileges", "users", column: "retired_by"
  add_foreign_key "role_privilege_mappings", "privileges"
  add_foreign_key "role_privilege_mappings", "roles"
  add_foreign_key "role_privilege_mappings", "users", column: "creator"
  add_foreign_key "role_privilege_mappings", "users", column: "voided_by"
  add_foreign_key "roles", "users", column: "creator"
  add_foreign_key "roles", "users", column: "retired_by"
  add_foreign_key "specimen", "users", column: "creator"
  add_foreign_key "specimen", "users", column: "retired_by"
  add_foreign_key "specimen_test_type_mappings", "specimen", column: "specimen_id"
  add_foreign_key "specimen_test_type_mappings", "test_types"
  add_foreign_key "specimen_test_type_mappings", "users", column: "creator"
  add_foreign_key "specimen_test_type_mappings", "users", column: "retired_by"
  add_foreign_key "status_reasons", "users", column: "creator"
  add_foreign_key "status_reasons", "users", column: "retired_by"
  add_foreign_key "statuses", "users", column: "creator"
  add_foreign_key "statuses", "users", column: "retired_by"
  add_foreign_key "surveillances", "diseases", column: "diseases_id"
  add_foreign_key "surveillances", "test_types", column: "test_types_id"
  add_foreign_key "surveillances", "users", column: "creator"
  add_foreign_key "surveillances", "users", column: "voided_by"
  add_foreign_key "test_indicator_ranges", "test_indicators"
  add_foreign_key "test_indicator_ranges", "users", column: "creator"
  add_foreign_key "test_indicator_ranges", "users", column: "retired_by"
  add_foreign_key "test_indicators", "test_types"
  add_foreign_key "test_indicators", "users", column: "creator"
  add_foreign_key "test_indicators", "users", column: "retired_by"
  add_foreign_key "test_panels", "users", column: "creator"
  add_foreign_key "test_panels", "users", column: "retired_by"
  add_foreign_key "test_results", "test_indicators"
  add_foreign_key "test_results", "tests"
  add_foreign_key "test_results", "users", column: "creator"
  add_foreign_key "test_results", "users", column: "voided_by"
  add_foreign_key "test_statuses", "status_reasons"
  add_foreign_key "test_statuses", "statuses"
  add_foreign_key "test_statuses", "tests"
  add_foreign_key "test_statuses", "users", column: "creator"
  add_foreign_key "test_statuses", "users", column: "voided_by"
  add_foreign_key "test_type_organism_mappings", "organisms"
  add_foreign_key "test_type_organism_mappings", "test_types"
  add_foreign_key "test_type_organism_mappings", "users", column: "creator"
  add_foreign_key "test_type_organism_mappings", "users", column: "retired_by"
  add_foreign_key "test_type_panel_mappings", "test_panels"
  add_foreign_key "test_type_panel_mappings", "test_types"
  add_foreign_key "test_type_panel_mappings", "users", column: "creator"
  add_foreign_key "test_type_panel_mappings", "users", column: "voided_by"
  add_foreign_key "test_types", "departments"
  add_foreign_key "test_types", "users", column: "creator"
  add_foreign_key "test_types", "users", column: "retired_by"
  add_foreign_key "tests", "orders"
  add_foreign_key "tests", "specimen", column: "specimen_id"
  add_foreign_key "tests", "test_panels"
  add_foreign_key "tests", "test_types"
  add_foreign_key "tests", "users", column: "creator"
  add_foreign_key "tests", "users", column: "voided_by"
  add_foreign_key "user_department_mappings", "departments"
  add_foreign_key "user_department_mappings", "users"
  add_foreign_key "user_department_mappings", "users", column: "creator"
  add_foreign_key "user_department_mappings", "users", column: "retired_by"
  add_foreign_key "user_role_mappings", "roles"
  add_foreign_key "user_role_mappings", "users"
  add_foreign_key "user_role_mappings", "users", column: "creator"
  add_foreign_key "user_role_mappings", "users", column: "retired_by"
  add_foreign_key "users", "people"
  add_foreign_key "users", "users", column: "creator"
  add_foreign_key "users", "users", column: "voided_by"
  add_foreign_key "visit_type_facility_section_mappings", "facility_sections"
  add_foreign_key "visit_type_facility_section_mappings", "users", column: "creator"
  add_foreign_key "visit_type_facility_section_mappings", "users", column: "retired_by"
  add_foreign_key "visit_type_facility_section_mappings", "visit_types"
  add_foreign_key "visit_types", "users", column: "creator"
  add_foreign_key "visit_types", "users", column: "retired_by"
end
