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

ActiveRecord::Schema.define(:version => 20120326214633) do

  create_table "addresses", :force => true do |t|
    t.integer  "customer_id"
    t.string   "street"
    t.integer  "postal_code"
    t.string   "city"
    t.string   "country"
    t.integer  "category_id"
    t.integer  "created_by"
    t.integer  "updated_by"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "delivery_rejection_id"
    t.integer  "referee_id"
    t.string   "company_name"
    t.string   "code"
  end

  create_table "article_groups", :force => true do |t|
    t.text     "description"
    t.integer  "warn_on"
    t.integer  "baan_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "warn_on_price"
  end

  create_table "articles", :force => true do |t|
    t.string   "baan_acces_id"
    t.string   "article_code"
    t.integer  "depot_id"
    t.integer  "article_type"
    t.string   "signal_code_description"
    t.string   "description"
    t.string   "search_key_01"
    t.string   "search_key_02"
    t.string   "material"
    t.string   "factor"
    t.string   "zone_code"
    t.string   "stock_unit"
    t.string   "order_unit"
    t.string   "trade_partner_name"
    t.string   "trade_partner_additional_info"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "rack_group_number"
    t.string   "rack_root_number"
    t.string   "rack_part_number"
    t.string   "rack_tray_number"
    t.string   "rack_box_number"
    t.string   "in_stock"
    t.string   "old_stock"
    t.integer  "article_group_id"
    t.decimal  "price",                         :precision => 12, :scale => 2
    t.boolean  "should_be_checked"
    t.string   "baan_orno"
    t.string   "baan_cntn"
    t.string   "baan_pono"
    t.string   "baan_loca"
    t.string   "baan_clot"
    t.string   "baan_qstk"
    t.string   "baan_qstr"
    t.string   "baan_csts"
    t.string   "baan_recd"
    t.string   "baan_item"
    t.string   "baan_date"
    t.string   "baan_stun"
    t.string   "baan_reco"
    t.string   "baan_appr"
    t.string   "baan_cadj"
    t.boolean  "considered"
    t.string   "baan_vstk"
    t.string   "baan_vstr"
    t.string   "baan_cstk"
    t.string   "baan_cstr"
    t.string   "rack_root_part_number"
  end

  create_table "baan_import_groups", :force => true do |t|
    t.string   "title"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "baan_imports", :force => true do |t|
    t.integer  "baan_import_group_id"
    t.date     "importing_date"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "baan_upload_file_name"
    t.string   "baan_upload_content_type"
    t.integer  "baan_upload_file_size"
    t.datetime "baan_upload_updated_at"
  end

  create_table "calculations", :force => true do |t|
    t.integer  "total_pallets"
    t.integer  "total_purchase_positions"
    t.integer  "calculable_id"
    t.string   "calculable_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "cargo_list_delivery_rejection_assignments", :force => true do |t|
    t.integer  "delivery_rejection_id"
    t.integer  "cargo_list_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "cargo_lists", :force => true do |t|
    t.datetime "pick_up_time_earliest"
    t.datetime "pick_up_time_latest"
    t.integer  "shipper_id"
    t.integer  "shipper_location_id"
    t.integer  "customer_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "delivered",                                               :default => false
    t.string   "referee"
    t.integer  "zip"
    t.string   "country"
    t.string   "street"
    t.string   "city"
    t.decimal  "vat",                      :precision => 12, :scale => 2
    t.decimal  "effective_invoice_amount", :precision => 12, :scale => 2
    t.decimal  "subtotal",                 :precision => 12, :scale => 2
    t.decimal  "total_amount",             :precision => 12, :scale => 2
  end

  create_table "categories", :force => true do |t|
    t.string   "title"
    t.text     "description"
    t.string   "categorizable_type"
    t.integer  "created_by"
    t.integer  "updated_by"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "comments", :force => true do |t|
    t.string   "subject"
    t.text     "content"
    t.integer  "commentable_id"
    t.string   "commentable_type"
    t.integer  "created_by"
    t.integer  "updated_by"
    t.datetime "created_at"
    t.datetime "updated_at"
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

  create_table "delivery_rejections", :force => true do |t|
    t.integer  "customer_id"
    t.integer  "referee_id"
    t.integer  "address_id"
    t.integer  "category_id"
    t.integer  "status_id"
    t.integer  "created_by"
    t.integer  "updated_by"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "cargo_list_id"
    t.float    "discount"
  end

  create_table "depot_types", :force => true do |t|
    t.string   "title"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "depots", :force => true do |t|
    t.integer  "code"
    t.text     "description"
    t.integer  "depot_type_id"
    t.string   "address_code"
    t.string   "phone_number"
    t.string   "fax_number"
    t.string   "web_address"
    t.datetime "created_at"
    t.datetime "updated_at"
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

  create_table "pallet_purchase_position_assignments", :force => true do |t|
    t.integer  "pallet_id"
    t.integer  "purchase_position_id"
    t.integer  "quantity"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.decimal  "amount",               :precision => 12, :scale => 2
    t.decimal  "weight",               :precision => 12, :scale => 2
    t.decimal  "reduced_price",        :precision => 12, :scale => 2
    t.decimal  "gross_price",          :precision => 12, :scale => 2
    t.decimal  "net_price",            :precision => 12, :scale => 2
    t.decimal  "value_discount",       :precision => 12, :scale => 2
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
    t.decimal  "amount",                :precision => 10, :scale => 0
    t.decimal  "weight_total",          :precision => 10, :scale => 0
    t.datetime "delivery_date"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.float    "additional_space",                                     :default => 0.0
    t.integer  "pallet_type_id"
    t.boolean  "delivered",                                            :default => false
    t.integer  "delivery_rejection_id"
  end

  create_table "purchase_order_address_assignments", :force => true do |t|
    t.integer  "purchase_order_id"
    t.integer  "address_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "purchase_order_pallet_assignments", :force => true do |t|
    t.integer  "purchase_order_id"
    t.integer  "pallet_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "purchase_orders", :force => true do |t|
    t.integer  "customer_id"
    t.string   "baan_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "status"
    t.integer  "shipping_route_id"
    t.date     "delivery_date"
    t.boolean  "delivered",               :default => false
    t.integer  "address_id"
    t.integer  "level_1"
    t.integer  "level_2"
    t.integer  "level_3"
    t.integer  "stock_status",            :default => 0
    t.integer  "production_status",       :default => 0
    t.string   "workflow_status",         :default => "00"
    t.float    "manufacturing_completed", :default => 0.0
    t.float    "warehousing_completed",   :default => 0.0
    t.integer  "warehouse_number",        :default => 0
  end

  create_table "purchase_positions", :force => true do |t|
    t.integer  "purchase_order_id"
    t.integer  "commodity_code_id"
    t.decimal  "weight_single",     :precision => 12, :scale => 2
    t.decimal  "weight_total",      :precision => 12, :scale => 2
    t.integer  "quantity"
    t.decimal  "amount",            :precision => 12, :scale => 2
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
    t.decimal  "total_amount",      :precision => 12, :scale => 2
    t.string   "consignee_full"
    t.boolean  "delivered",                                        :default => false
    t.integer  "zip_location_id"
    t.string   "zip_location_name"
    t.string   "baan_id"
    t.decimal  "gross_price",       :precision => 12, :scale => 2
    t.decimal  "net_price",         :precision => 12, :scale => 2
    t.decimal  "value_discount",    :precision => 12, :scale => 2
    t.integer  "production_status",                                :default => 0
    t.integer  "stock_status",                                     :default => 0
  end

  create_table "referees", :force => true do |t|
    t.integer  "customer_id"
    t.string   "forename"
    t.string   "surname"
    t.string   "phone_number"
    t.string   "email"
    t.integer  "created_by"
    t.integer  "updated_by"
    t.datetime "created_at"
    t.datetime "updated_at"
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

  create_table "statuses", :force => true do |t|
    t.string   "title"
    t.text     "description"
    t.integer  "created_by"
    t.integer  "updated_by"
    t.string   "statusable_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "transport_issues", :force => true do |t|
    t.integer  "purchase_position_id"
    t.integer  "delivery_rejection_id"
    t.integer  "created_by"
    t.integer  "updated_by"
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
    t.string   "single_access_token",                :null => false
    t.string   "perishable_token",                   :null => false
    t.integer  "login_count",         :default => 0, :null => false
    t.integer  "failed_login_count",  :default => 0, :null => false
    t.datetime "last_request_at"
    t.datetime "current_login_at"
    t.datetime "last_login_at"
    t.string   "current_login_ip"
    t.string   "last_login_ip"
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
