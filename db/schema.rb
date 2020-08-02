# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2020_07_29_113449) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "choice1s", force: :cascade do |t|
    t.bigint "question_id"
    t.bigint "player_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["player_id"], name: "index_choice1s_on_player_id"
    t.index ["question_id"], name: "index_choice1s_on_question_id"
  end

  create_table "choice2s", force: :cascade do |t|
    t.bigint "question_id"
    t.bigint "player_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["player_id"], name: "index_choice2s_on_player_id"
    t.index ["question_id"], name: "index_choice2s_on_question_id"
  end

  create_table "choice3s", force: :cascade do |t|
    t.bigint "question_id"
    t.bigint "player_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["player_id"], name: "index_choice3s_on_player_id"
    t.index ["question_id"], name: "index_choice3s_on_question_id"
  end

  create_table "choice4s", force: :cascade do |t|
    t.bigint "question_id"
    t.bigint "player_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["player_id"], name: "index_choice4s_on_player_id"
    t.index ["question_id"], name: "index_choice4s_on_question_id"
  end

  create_table "games", force: :cascade do |t|
    t.string "name"
    t.bigint "started_by_id"
    t.integer "total_players_num"
    t.boolean "has_started"
    t.boolean "winner_found"
    t.bigint "winner_id"
    t.boolean "game_ended"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["started_by_id"], name: "index_games_on_started_by_id"
    t.index ["winner_id"], name: "index_games_on_winner_id"
  end

  create_table "games_players", id: false, force: :cascade do |t|
    t.bigint "game_id", null: false
    t.bigint "player_id", null: false
  end

  create_table "games_questions", id: false, force: :cascade do |t|
    t.bigint "game_id", null: false
    t.bigint "question_id", null: false
  end

  create_table "players", force: :cascade do |t|
    t.string "nickname"
    t.string "uuid"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "questions", force: :cascade do |t|
    t.integer "position"
    t.bigint "trivium_id"
    t.datetime "expires_at"
    t.integer "choice1_num"
    t.integer "choice2_num"
    t.integer "choice3_num"
    t.integer "choice4_num"
    t.integer "choice5_num"
    t.boolean "winner_found"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["trivium_id"], name: "index_questions_on_trivium_id"
  end

  create_table "trivia", force: :cascade do |t|
    t.string "text"
    t.string "correct_answer"
    t.string "choice1"
    t.string "choice2"
    t.string "choice3"
    t.string "choice4"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

end
