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

ActiveRecord::Schema[7.1].define(version: 2025_09_03_055351) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "breeds", force: :cascade do |t|
    t.string "name"
    t.jsonb "risk_tags"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "events", force: :cascade do |t|
    t.string "title"
    t.text "description"
    t.string "event_type"
    t.datetime "scheduled_at"
    t.string "status", default: "pending"
    t.datetime "completed_at"
    t.string "subject_type", null: false
    t.bigint "subject_id", null: false
    t.bigint "household_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "kind"
    t.date "scheduled_on"
    t.time "scheduled_time"
    t.integer "remind_before_minutes"
    t.text "note"
    t.index ["household_id"], name: "index_events_on_household_id"
    t.index ["subject_type", "subject_id"], name: "index_events_on_subject"
  end

  create_table "health_risk_rules", force: :cascade do |t|
    t.jsonb "trigger_conditions"
    t.text "message"
    t.integer "priority"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "households", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "medication_plans", force: :cascade do |t|
    t.string "name"
    t.decimal "dosage_mg_per_kg"
    t.integer "interval_days"
    t.date "season_from"
    t.date "season_to"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "memberships", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "household_id", null: false
    t.string "role"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["household_id"], name: "index_memberships_on_household_id"
    t.index ["user_id"], name: "index_memberships_on_user_id"
  end

  create_table "notifications", force: :cascade do |t|
    t.bigint "pet_id", null: false
    t.string "notification_type"
    t.string "title"
    t.text "message"
    t.datetime "scheduled_for"
    t.string "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["pet_id"], name: "index_notifications_on_pet_id"
  end

  create_table "pets", force: :cascade do |t|
    t.string "name"
    t.string "species"
    t.string "sex"
    t.date "birthdate"
    t.bigint "household_id", null: false
    t.string "profile_image"
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "breed_id"
    t.decimal "weight_kg"
    t.index ["breed_id"], name: "index_pets_on_breed_id"
    t.index ["household_id"], name: "index_pets_on_household_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "name"
    t.string "profile_image"
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  create_table "vaccinations", force: :cascade do |t|
    t.bigint "pet_id", null: false
    t.bigint "vaccine_id", null: false
    t.date "due_on"
    t.string "status"
    t.datetime "completed_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["pet_id"], name: "index_vaccinations_on_pet_id"
    t.index ["vaccine_id"], name: "index_vaccinations_on_vaccine_id"
  end

  create_table "vaccine_schedule_rules", force: :cascade do |t|
    t.bigint "vaccine_id", null: false
    t.integer "min_age_weeks"
    t.integer "repeat_every_days"
    t.integer "booster_times"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["vaccine_id"], name: "index_vaccine_schedule_rules_on_vaccine_id"
  end

  create_table "vaccines", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "walk_logs", force: :cascade do |t|
    t.bigint "pet_id", null: false
    t.date "date", null: false
    t.decimal "distance_km", precision: 5, scale: 1, null: false
    t.integer "duration_minutes", null: false
    t.text "note"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["pet_id", "date"], name: "index_walk_logs_on_pet_id_and_date", unique: true
    t.index ["pet_id"], name: "index_walk_logs_on_pet_id"
  end

  create_table "weight_records", force: :cascade do |t|
    t.bigint "pet_id", null: false
    t.date "date", null: false
    t.decimal "weight_kg", precision: 5, scale: 1, null: false
    t.text "note"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["pet_id", "date"], name: "index_weight_records_on_pet_id_and_date", unique: true
    t.index ["pet_id"], name: "index_weight_records_on_pet_id"
  end

  add_foreign_key "events", "households"
  add_foreign_key "memberships", "households"
  add_foreign_key "memberships", "users"
  add_foreign_key "notifications", "pets"
  add_foreign_key "pets", "breeds"
  add_foreign_key "pets", "households"
  add_foreign_key "vaccinations", "pets"
  add_foreign_key "vaccinations", "vaccines"
  add_foreign_key "vaccine_schedule_rules", "vaccines"
  add_foreign_key "walk_logs", "pets"
  add_foreign_key "weight_records", "pets"
end
