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

ActiveRecord::Schema[8.1].define(version: 2026_02_07_013401) do
  create_table "active_storage_attachments", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.bigint "record_id", null: false
    t.string "record_type", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.string "content_type"
    t.datetime "created_at", null: false
    t.string "filename", null: false
    t.string "key", null: false
    t.text "metadata"
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "docs", force: :cascade do |t|
    t.text "content"
    t.datetime "created_at", null: false
    t.string "language", null: false
    t.integer "original_doc_id", null: false
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.index ["original_doc_id", "language"], name: "index_docs_on_original_doc_id_and_language", unique: true
    t.index ["original_doc_id"], name: "index_docs_on_original_doc_id"
  end

  create_table "original_docs", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "original_file"
    t.integer "school_id", null: false
    t.string "status", default: "pending"
    t.datetime "updated_at", null: false
    t.datetime "uploaded_at"
    t.integer "uploader_id", null: false
    t.index ["school_id"], name: "index_original_docs_on_school_id"
    t.index ["uploaded_at"], name: "index_original_docs_on_uploaded_at"
    t.index ["uploader_id"], name: "index_original_docs_on_uploader_id"
  end

  create_table "schools", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "location"
    t.string "name", null: false
    t.datetime "updated_at", null: false
    t.index ["location"], name: "index_schools_on_location"
    t.index ["name"], name: "index_schools_on_name", unique: true
  end

  create_table "sessions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "ip_address"
    t.datetime "updated_at", null: false
    t.string "user_agent"
    t.integer "user_id", null: false
    t.index ["user_id"], name: "index_sessions_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.boolean "admin", default: false
    t.datetime "created_at", null: false
    t.string "email_address", null: false
    t.string "password_digest", null: false
    t.integer "school_id"
    t.string "selected_lang", default: "ko"
    t.datetime "updated_at", null: false
    t.index ["email_address"], name: "index_users_on_email_address", unique: true
    t.index ["school_id"], name: "index_users_on_school_id"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "docs", "original_docs"
  add_foreign_key "original_docs", "schools"
  add_foreign_key "original_docs", "users", column: "uploader_id"
  add_foreign_key "sessions", "users"
  add_foreign_key "users", "schools"
end
