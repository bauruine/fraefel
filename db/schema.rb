# encoding: UTF-8
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

ActiveRecord::Schema.define(:version => 20141221203410) do

  create_table "addresses", :force => true do |t|
    t.integer "customer_id"
    t.string  "street"
    t.integer "postal_code"
    t.string  "city"
    t.string  "country"
    t.integer "category_id"
    t.integer "created_by"
    t.integer "updated_by"
    t.integer "delivery_rejection_id"
    t.integer "referee_id"
    t.string  "company_name"
    t.string  "code"
    t.string  "eori"
  end

  add_index "addresses", ["category_id"], :name => "index_addresses_on_category_id"
  add_index "addresses", ["code"], :name => "index_addresses_on_code"
  add_index "addresses", ["company_name"], :name => "index_addresses_on_company_name"
  add_index "addresses", ["country"], :name => "index_addresses_on_country"
  add_index "addresses", ["customer_id"], :name => "index_addresses_on_customer_id"
  add_index "addresses", ["eori"], :name => "index_addresses_on_eori"

  create_table "article_groups", :force => true do |t|
    t.text     "description"
    t.integer  "warn_on"
    t.integer  "baan_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "warn_on_price"
    t.string   "stocktaking_id"
  end

  create_table "article_position_time_shifting_assignments", :force => true do |t|
    t.integer  "article_position_id"
    t.integer  "time_shifting_id"
    t.integer  "created_by"
    t.integer  "updated_by"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "order_number"
    t.date     "confirmed_date"
    t.string   "purchase_positions_collection"
  end

  create_table "article_positions", :force => true do |t|
    t.string   "baan_id"
    t.integer  "created_by"
    t.integer  "updated_by"
    t.datetime "created_at"
    t.datetime "updated_at"
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
    t.string   "stocktaking_id"
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

  create_table "baan_raw_data", :force => true do |t|
    t.integer  "baan_import_id"
    t.string   "baan_0",         :limit => 50
    t.string   "baan_1",         :limit => 50
    t.string   "baan_2",         :limit => 50
    t.string   "baan_3",         :limit => 50
    t.string   "baan_4",         :limit => 50
    t.string   "baan_5",         :limit => 50
    t.string   "baan_6",         :limit => 50
    t.string   "baan_7",         :limit => 50
    t.string   "baan_8",         :limit => 50
    t.string   "baan_9",         :limit => 50
    t.string   "baan_10",        :limit => 50
    t.string   "baan_11",        :limit => 50
    t.string   "baan_12",        :limit => 50
    t.string   "baan_13",        :limit => 50
    t.string   "baan_14",        :limit => 50
    t.string   "baan_15",        :limit => 50
    t.string   "baan_16",        :limit => 50
    t.string   "baan_17",        :limit => 50
    t.string   "baan_18",        :limit => 50
    t.string   "baan_19",        :limit => 50
    t.string   "baan_20",        :limit => 50
    t.string   "baan_21",        :limit => 50
    t.string   "baan_22",        :limit => 50
    t.string   "baan_23",        :limit => 50
    t.string   "baan_24",        :limit => 50
    t.string   "baan_25",        :limit => 50
    t.string   "baan_26",        :limit => 50
    t.string   "baan_27",        :limit => 50
    t.string   "baan_28",        :limit => 50
    t.string   "baan_29",        :limit => 50
    t.string   "baan_30",        :limit => 50
    t.string   "baan_31",        :limit => 50
    t.string   "baan_32",        :limit => 50
    t.string   "baan_33",        :limit => 50
    t.string   "baan_34",        :limit => 50
    t.string   "baan_35",        :limit => 50
    t.string   "baan_36",        :limit => 50
    t.string   "baan_37",        :limit => 50
    t.string   "baan_38",        :limit => 50
    t.string   "baan_39",        :limit => 50
    t.string   "baan_40",        :limit => 50
    t.string   "baan_41",        :limit => 50
    t.string   "baan_42",        :limit => 50
    t.string   "baan_43",        :limit => 50
    t.string   "baan_44",        :limit => 50
    t.string   "baan_45",        :limit => 50
    t.string   "baan_46",        :limit => 50
    t.string   "baan_47",        :limit => 50
    t.string   "baan_48",        :limit => 50
    t.string   "baan_49",        :limit => 50
    t.string   "baan_50",        :limit => 50
    t.string   "baan_51",        :limit => 50
    t.string   "baan_52",        :limit => 50
    t.string   "baan_53",        :limit => 50
    t.string   "baan_54",        :limit => 50
    t.string   "baan_55",        :limit => 50
    t.string   "baan_56",        :limit => 50
    t.string   "baan_57",        :limit => 50
    t.string   "baan_58",        :limit => 50
    t.string   "baan_59",        :limit => 50
    t.string   "baan_60",        :limit => 50
    t.string   "baan_61",        :limit => 50
    t.string   "baan_62",        :limit => 50
    t.string   "baan_63",        :limit => 50
    t.string   "baan_64",        :limit => 50
    t.string   "baan_65",        :limit => 50
    t.string   "baan_66",        :limit => 50
    t.string   "baan_67",        :limit => 50
    t.string   "baan_68",        :limit => 50
    t.string   "baan_69",        :limit => 50
    t.string   "baan_70",        :limit => 50
    t.string   "baan_71",        :limit => 50
    t.string   "baan_72",        :limit => 50
    t.string   "baan_73",        :limit => 50
    t.string   "baan_74",        :limit => 50
    t.string   "baan_75",        :limit => 50
    t.string   "baan_76",        :limit => 50
    t.string   "baan_77",        :limit => 50
    t.string   "baan_78",        :limit => 50
    t.string   "baan_79",        :limit => 50
    t.string   "baan_80",        :limit => 50
    t.string   "baan_81",        :limit => 50
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "baan_82",        :limit => 50
    t.string   "baan_83",        :limit => 50
    t.string   "baan_84",        :limit => 50
    t.string   "baan_85",        :limit => 50
    t.string   "baan_86",        :limit => 50
    t.string   "baan_87",        :limit => 50
  end

  create_table "calculations", :force => true do |t|
    t.integer  "total_pallets",            :default => 0
    t.integer  "total_purchase_positions", :default => 0
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
    t.boolean  "delivered",             :default => false
    t.string   "referee"
    t.string   "country"
    t.integer  "pallets_count",         :default => 0
    t.integer  "level_3"
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

  create_table "delivery_dates", :force => true do |t|
    t.date     "date_of_delivery"
    t.integer  "dateable_id"
    t.string   "dateable_type"
    t.integer  "created_by"
    t.integer  "updated_by"
    t.datetime "created_at"
    t.datetime "updated_at"
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
    t.boolean  "closed",              :default => false
    t.integer  "delivery_address_id"
    t.integer  "pick_up_address_id"
    t.integer  "invoice_address_id"
  end

  create_table "department_shifting_reason_assignments", :force => true do |t|
    t.integer  "department_id"
    t.integer  "shifting_reason_id"
    t.integer  "created_by"
    t.integer  "updated_by"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "department_time_shifting_assignments", :force => true do |t|
    t.integer  "time_shifting_id"
    t.integer  "department_id"
    t.integer  "created_by"
    t.integer  "updated_by"
    t.datetime "completed_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "department_user_assignments", :force => true do |t|
    t.integer  "user_id"
    t.integer  "department_id"
    t.integer  "created_by"
    t.integer  "updated_by"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "departments", :force => true do |t|
    t.string   "title"
    t.integer  "created_by"
    t.integer  "updated_by"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "abbreviation"
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
    t.string   "stocktaking_id"
  end

  create_table "html_contents", :force => true do |t|
    t.text    "code"
    t.integer "purchase_order_id"
    t.integer "purchase_position_id"
    t.integer "category_id"
    t.integer "pallet_id"
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
    t.decimal  "amount",                :precision => 12, :scale => 2
    t.decimal  "weight",                :precision => 12, :scale => 2
    t.decimal  "reduced_price",         :precision => 12, :scale => 2
    t.decimal  "gross_price",           :precision => 12, :scale => 2
    t.decimal  "net_price",             :precision => 12, :scale => 2
    t.decimal  "value_discount",        :precision => 12, :scale => 2
    t.boolean  "is_individual_package",                                :default => false
  end

  create_table "pallet_types", :force => true do |t|
    t.string "description"
    t.float  "count_as"
    t.string "read_as"
  end

  create_table "pallets", :force => true do |t|
    t.integer "cargo_list_id"
    t.float   "additional_space",      :default => 0.0
    t.integer "pallet_type_id"
    t.boolean "delivered",             :default => false
    t.integer "delivery_rejection_id"
    t.integer "level_3"
    t.integer "zip_location_id"
    t.boolean "mixed",                 :default => false
    t.integer "shipping_route_id"
    t.integer "line_items_quantity",   :default => 0
  end

  create_table "pdf_reports", :force => true do |t|
    t.string   "pdf_type"
    t.integer  "user_id"
    t.string   "searched_for"
    t.string   "report_file_name"
    t.string   "report_file_path"
    t.boolean  "saved_local"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "printable_media", :force => true do |t|
    t.string "title"
  end

  create_table "printable_media_shipping_route_assignments", :force => true do |t|
    t.integer "printable_media_id"
    t.integer "shipping_route_id"
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
    t.integer  "shipping_route_id"
    t.date     "delivery_date"
    t.boolean  "delivered",                             :default => false
    t.integer  "address_id"
    t.integer  "level_1"
    t.integer  "level_2"
    t.integer  "level_3"
    t.integer  "stock_status",                          :default => 0
    t.integer  "production_status",                     :default => 0
    t.string   "workflow_status",                       :default => "00"
    t.float    "manufacturing_completed",               :default => 0.0
    t.float    "warehousing_completed",                 :default => 0.0
    t.integer  "warehouse_number",                      :default => 0
    t.integer  "category_id"
    t.integer  "priority_level",                        :default => 1
    t.boolean  "picked_up",                             :default => false
    t.integer  "pending_status",                        :default => 0
    t.boolean  "cancelled",                             :default => false
    t.string   "additional_1",            :limit => 50
    t.string   "additional_2",            :limit => 50
    t.string   "additional_3",            :limit => 50
  end

  add_index "purchase_orders", ["baan_id"], :name => "index_purchase_orders_on_baan_id", :unique => true
  add_index "purchase_orders", ["cancelled"], :name => "index_purchase_orders_on_cancelled"
  add_index "purchase_orders", ["category_id"], :name => "index_purchase_orders_on_category_id"
  add_index "purchase_orders", ["delivered"], :name => "index_purchase_orders_on_delivered"
  add_index "purchase_orders", ["level_1"], :name => "index_purchase_orders_on_level_1"
  add_index "purchase_orders", ["level_2"], :name => "index_purchase_orders_on_level_2"
  add_index "purchase_orders", ["level_3"], :name => "index_purchase_orders_on_level_3"
  add_index "purchase_orders", ["pending_status"], :name => "index_purchase_orders_on_pending_status"
  add_index "purchase_orders", ["picked_up"], :name => "index_purchase_orders_on_picked_up"
  add_index "purchase_orders", ["priority_level"], :name => "index_purchase_orders_on_priority_level"
  add_index "purchase_orders", ["production_status"], :name => "index_purchase_orders_on_production_status"
  add_index "purchase_orders", ["shipping_route_id"], :name => "index_purchase_orders_on_shipping_route_id"
  add_index "purchase_orders", ["stock_status"], :name => "index_purchase_orders_on_stock_status"
  add_index "purchase_orders", ["warehouse_number"], :name => "index_purchase_orders_on_warehouse_number"

  create_table "purchase_position_time_shifting_assignments", :force => true do |t|
    t.integer  "purchase_position_id"
    t.integer  "time_shifting_id"
    t.boolean  "considered"
    t.integer  "created_by"
    t.integer  "updated_by"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "purchase_positions", :force => true do |t|
    t.integer  "purchase_order_id"
    t.integer  "commodity_code_id"
    t.decimal  "weight_single",                   :precision => 12, :scale => 2
    t.decimal  "weight_total",                    :precision => 12, :scale => 2
    t.integer  "quantity"
    t.decimal  "amount",                          :precision => 12, :scale => 2
    t.date     "delivery_date"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "position"
    t.integer  "pallet_id"
    t.string   "product_line"
    t.string   "article"
    t.string   "storage_location"
    t.string   "article_number"
    t.decimal  "total_amount",                    :precision => 12, :scale => 2
    t.boolean  "delivered",                                                      :default => false
    t.integer  "zip_location_id"
    t.string   "baan_id"
    t.decimal  "gross_price",                     :precision => 12, :scale => 2
    t.decimal  "net_price",                       :precision => 12, :scale => 2
    t.decimal  "value_discount",                  :precision => 12, :scale => 2
    t.integer  "production_status",                                              :default => 0
    t.integer  "stock_status",                                                   :default => 0
    t.integer  "priority_level",                                                 :default => 1
    t.boolean  "picked_up",                                                      :default => false
    t.boolean  "cancelled",                                                      :default => false
    t.integer  "level_3"
    t.integer  "shipping_route_id"
    t.string   "additional_1",      :limit => 50
    t.string   "additional_2",      :limit => 50
    t.string   "additional_3",      :limit => 50
  end

  add_index "purchase_positions", ["baan_id"], :name => "index_purchase_positions_on_baan_id", :unique => true
  add_index "purchase_positions", ["commodity_code_id"], :name => "index_purchase_positions_on_commodity_code_id"
  add_index "purchase_positions", ["level_3"], :name => "index_purchase_positions_on_level_3"
  add_index "purchase_positions", ["shipping_route_id"], :name => "index_purchase_positions_on_shipping_route_id"
  add_index "purchase_positions", ["storage_location"], :name => "index_purchase_positions_on_storage_location"
  add_index "purchase_positions", ["zip_location_id"], :name => "index_purchase_positions_on_zip_location_id"

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

  create_table "shifting_reason_time_shifting_assignments", :force => true do |t|
    t.integer  "time_shifting_id"
    t.integer  "shifting_reason_id"
    t.integer  "created_by"
    t.integer  "updated_by"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "shifting_reasons", :force => true do |t|
    t.string   "title"
    t.integer  "created_by"
    t.integer  "updated_by"
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

  create_table "time_shiftings", :force => true do |t|
    t.boolean  "simple"
    t.string   "purchase_order_id"
    t.date     "delivery_date"
    t.integer  "created_by"
    t.integer  "updated_by"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "department_id"
    t.boolean  "customer_was_informed"
    t.boolean  "baan_was_updated"
    t.date     "we_date"
    t.date     "lt_date"
    t.boolean  "change_we_date"
    t.boolean  "change_lt_date"
    t.boolean  "closed",                :default => false
  end

  create_table "transport_issues", :force => true do |t|
    t.integer  "purchase_position_id"
    t.integer  "delivery_rejection_id"
    t.integer  "created_by"
    t.integer  "updated_by"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "user_role_assignments", :id => false, :force => true do |t|
    t.integer  "role_id"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", :force => true do |t|
    t.string   "username"
    t.string   "email",                  :default => "", :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "forename"
    t.string   "surname"
    t.string   "encrypted_password",     :default => "", :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "unconfirmed_email"
    t.integer  "failed_attempts",        :default => 0
    t.string   "unlock_token"
    t.datetime "locked_at"
    t.string   "authentication_token"
  end

  add_index "users", ["authentication_token"], :name => "index_users_on_authentication_token", :unique => true
  add_index "users", ["confirmation_token"], :name => "index_users_on_confirmation_token", :unique => true
  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true
  add_index "users", ["unlock_token"], :name => "index_users_on_unlock_token", :unique => true

  create_table "versions", :force => true do |t|
    t.string   "item_type",  :null => false
    t.integer  "item_id",    :null => false
    t.string   "event",      :null => false
    t.string   "whodunnit"
    t.text     "object"
    t.datetime "created_at"
  end

  add_index "versions", ["item_type", "item_id"], :name => "index_versions_on_item_type_and_item_id"

  create_table "zip_locations", :force => true do |t|
    t.string "title"
  end

end
