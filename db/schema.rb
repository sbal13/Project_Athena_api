# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20171003170449) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "assignments", force: :cascade do |t|
    t.string "title"
    t.string "assignment_type"
    t.string "subject"
    t.text "description"
    t.string "grade"
    t.string "difficulty"
    t.boolean "timed"
    t.float "time"
    t.string "total_points"
    t.integer "teacher_id"
    t.boolean "protected"
    t.integer "creator_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "historical", default: false
  end

  create_table "issued_assignments", force: :cascade do |t|
    t.integer "student_id"
    t.string "status"
    t.bigint "assignment_id"
    t.text "given_answers", default: [], array: true
    t.float "final_score"
    t.datetime "due_date"
    t.datetime "assigned_date"
    t.text "teacher_comments"
    t.datetime "finalized_date"
    t.float "question_points", default: [], array: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["assignment_id"], name: "index_issued_assignments_on_assignment_id"
  end

  create_table "questions", force: :cascade do |t|
    t.string "answer"
    t.string "choices", default: [], array: true
    t.integer "point_value"
    t.string "question"
    t.string "question_type"
    t.bigint "assignment_id"
    t.index ["assignment_id"], name: "index_questions_on_assignment_id"
  end

  create_table "teacher_students", force: :cascade do |t|
    t.integer "student_id"
    t.integer "teacher_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.string "first_name"
    t.string "last_name"
    t.text "description"
    t.string "teacher_key"
    t.text "subjects", default: [], array: true
    t.string "username"
    t.string "email"
    t.string "password_digest"
    t.string "user_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "issued_assignments", "assignments"
  add_foreign_key "questions", "assignments"
end
