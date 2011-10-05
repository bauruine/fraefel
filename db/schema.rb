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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20111004191149) do

  create_table "cargo_lists", :force => true do |t|
    t.datetime "pick_up_time_earliest"
    t.datetime "pick_up_time_latest"
    t.integer  "shipper_id"
    t.integer  "shipper_location_id"
    t.integer  "customer_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "delivered",             :default => false
    t.string   "referee"
    t.integer  "zip"
    t.string   "country"
    t.string   "street"
    t.string   "city"
  end

  create_table "commodity_codes", :force => true do |t|
    t.string   "code"
    t.text     "content"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "customers", :force => true do |t|
    t.string   "company"
    t.string   "referee"
    t.boolean  "active"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "baan_id"
  end

  create_table "microsoft_database_types", :force => true do |t|
    t.string   "name"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "microsoft_databases", :force => true do |t|
    t.string   "name"
    t.integer  "database_type_id"
    t.string   "file"
    t.string   "file_directory"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "pallet_types", :force => true do |t|
    t.string   "description"
    t.float    "count_as"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "pallets", :force => true do |t|
    t.integer  "purchase_order_id"
    t.integer  "cargo_list_id"
    t.decimal  "amount"
    t.decimal  "weight_total"
    t.datetime "delivery_date"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.decimal  "additional_space",  :default => 0.0
    t.integer  "pallet_type_id"
    t.boolean  "delivered",         :default => false
  end

  create_table "purchase_orders", :force => true do |t|
    t.integer  "customer_id"
    t.integer  "baan_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "status"
    t.integer  "shipping_route_id"
    t.date     "delivery_date"
    t.boolean  "delivered",         :default => false
  end

  create_table "purchase_positions", :force => true do |t|
    t.integer  "purchase_order_id"
    t.integer  "commodity_code_id"
    t.decimal  "weight_single"
    t.decimal  "weight_total"
    t.decimal  "quantity"
    t.decimal  "amount"
    t.datetime "delivery_date"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "position"
    t.string   "status"
    t.integer  "pallet_id"
    t.string   "product_line"
    t.string   "article"
    t.string   "storage_location"
    t.string   "article_number"
  end

  create_table "roles", :force => true do |t|
    t.string   "name"
    t.integer  "position"
    t.boolean  "active"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "roles_users", :id => false, :force => true do |t|
    t.integer  "role_id"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "shipper_locations", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "shippers", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "shipping_addresses", :force => true do |t|
    t.string   "street"
    t.integer  "zip"
    t.string   "city"
    t.string   "country"
    t.string   "fax"
    t.string   "phone_number"
    t.integer  "customer_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "shipping_routes", :force => true do |t|
    t.string   "name"
    t.boolean  "active"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", :force => true do |t|
    t.string   "username"
    t.string   "email"
    t.string   "crypted_password"
    t.string   "password_salt"
    t.string   "persistence_token"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "forename"
    t.string   "surname"
  end

  create_table "versions", :force => true do |t|
    t.string   "item_type",  :null => false
    t.integer  "item_id",    :null => false
    t.string   "event",      :null => false
    t.string   "whodunnit"
    t.text     "object"
    t.datetime "created_at"
  end

  add_index "versions", ["item_type", "item_id"], :name => "index_versions_on_item_type_and_item_id"

end
