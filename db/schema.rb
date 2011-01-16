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

ActiveRecord::Schema.define(:version => 20110108044310) do

  create_table "advanced_orders", :force => true do |t|
    t.integer  "court_id",                    :default => 0, :null => false
    t.date     "start_date",                                 :null => false
    t.date     "end_date",                                   :null => false
    t.integer  "wday",           :limit => 1, :default => 0, :null => false
    t.integer  "start_hour",     :limit => 1,                :null => false
    t.integer  "end_hour",       :limit => 1,                :null => false
    t.integer  "member_card_id",              :default => 0, :null => false
    t.integer  "member_id",                   :default => 0, :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "balances", :force => true do |t|
    t.integer  "order_id",                                                              :default => 0,   :null => false
    t.decimal  "book_record_amount",                     :precision => 10, :scale => 2, :default => 0.0, :null => false
    t.decimal  "book_record_realy_amount",               :precision => 10, :scale => 2, :default => 0.0, :null => false
    t.string   "change_note",              :limit => 80,                                :default => "",  :null => false
    t.integer  "catena_id",                                                             :default => 0,   :null => false
    t.integer  "balance_way",              :limit => 1,                                 :default => 0,   :null => false
    t.integer  "member_type",              :limit => 1,                                 :default => 0,   :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "goods_balance_type",       :limit => 1,                                 :default => 0,   :null => false
    t.integer  "status",                   :limit => 1,                                 :default => 0,   :null => false
    t.integer  "count_amount",                                                          :default => 0,   :null => false
    t.decimal  "goods_amount",                           :precision => 10, :scale => 0
    t.decimal  "goods_realy_amount",                     :precision => 10, :scale => 0, :default => 0
  end

  create_table "book_records", :force => true do |t|
    t.integer "court_id",                 :default => 0, :null => false
    t.integer "end_hour",    :limit => 1, :default => 0, :null => false
    t.integer "start_hour",  :limit => 1, :default => 0, :null => false
    t.date    "record_date",                             :null => false
    t.integer "status",      :limit => 1, :default => 0, :null => false
    t.integer "catena_id",                :default => 0, :null => false
  end

  create_table "card_period_prices", :force => true do |t|
    t.integer  "card_id",                                        :default => 1,   :null => false
    t.integer  "period_price_id",                                :default => 1,   :null => false
    t.decimal  "card_price",      :precision => 10, :scale => 2, :default => 0.0, :null => false
    t.text     "description"
    t.integer  "catena_id",                                      :default => 0,   :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "cards", :force => true do |t|
    t.string   "name",                                         :default => "",  :null => false
    t.integer  "card_type",                                    :default => 1,   :null => false
    t.string   "card_prefix",                                  :default => "",  :null => false
    t.integer  "consume_type",                                 :default => 0
    t.integer  "is_shared",                                    :default => 0
    t.integer  "shared_amount",                                :default => 0
    t.integer  "sale_amount",                                  :default => 0
    t.integer  "catena_id",                                    :default => 0,   :null => false
    t.string   "description",                                                   :null => false
    t.integer  "counts",                                       :default => 0
    t.decimal  "balance",       :precision => 10, :scale => 2, :default => 0.0
    t.integer  "status",                                       :default => 0,   :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "expired",                                      :default => 12,  :null => false
  end

  create_table "catenas", :force => true do |t|
    t.string   "name",        :default => "", :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "description"
    t.integer  "status",      :default => 1
    t.string   "contact"
    t.string   "telephone"
  end

  create_table "coaches", :force => true do |t|
    t.string   "name",                                       :default => "",  :null => false
    t.integer  "gender",                                     :default => 0,   :null => false
    t.string   "portrait"
    t.integer  "coach_type",                                 :default => 0,   :null => false
    t.string   "telephone",                                                   :null => false
    t.string   "email",                                                       :null => false
    t.decimal  "fee",         :precision => 10, :scale => 2, :default => 0.0, :null => false
    t.integer  "cert_type",                                                   :null => false
    t.string   "cert_num",                                                    :null => false
    t.text     "description"
    t.integer  "status",                                     :default => 0,   :null => false
    t.integer  "catena_id",                                  :default => 0,   :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "common_resource_details", :force => true do |t|
    t.integer  "common_resource_id",                 :null => false
    t.string   "detail_name",        :default => "", :null => false
    t.integer  "status",             :default => 0,  :null => false
    t.integer  "catena_id",          :default => 0,  :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "common_resources", :force => true do |t|
    t.string   "name",                       :null => false
    t.text     "description"
    t.text     "detail_str"
    t.integer  "catena_id",   :default => 0, :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "court_period_prices", :force => true do |t|
    t.integer  "court_id",                                                        :null => false
    t.integer  "period_price_id",                                                 :null => false
    t.decimal  "court_price",     :precision => 10, :scale => 2, :default => 0.0, :null => false
    t.text     "description"
    t.integer  "status",                                         :default => 0,   :null => false
    t.integer  "catena_id",                                      :default => 0,   :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "courts", :force => true do |t|
    t.string   "name",        :default => "", :null => false
    t.string   "contact",     :default => "", :null => false
    t.string   "telephone"
    t.integer  "start_time",                  :null => false
    t.integer  "end_time",                    :null => false
    t.text     "description"
    t.integer  "status",      :default => 1,  :null => false
    t.integer  "catena_id",   :default => 0,  :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "department_powers", :force => true do |t|
    t.integer  "department_id",                :null => false
    t.integer  "power_id",                     :null => false
    t.integer  "catena_id",     :default => 1, :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "department_users", :force => true do |t|
    t.integer "user_id",                      :null => false
    t.integer "department_id",                :null => false
    t.integer "catena_id",     :default => 1, :null => false
  end

  create_table "departments", :force => true do |t|
    t.string  "name",      :limit => 50, :default => "", :null => false
    t.integer "catena_id",               :default => 1,  :null => false
  end

  create_table "goods", :force => true do |t|
    t.string   "name",                                                 :default => "",  :null => false
    t.integer  "good_type",                                                             :null => false
    t.decimal  "purchasing_price",      :precision => 10, :scale => 2, :default => 0.0, :null => false
    t.decimal  "price",                 :precision => 10, :scale => 2, :default => 0.0, :null => false
    t.integer  "status",                                               :default => 0,   :null => false
    t.integer  "catena_id",                                            :default => 0,   :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "count_total_now",                                      :default => 0,   :null => false
    t.integer  "count_back_stock",                                     :default => 0,   :null => false
    t.integer  "count_front_stock",                                    :default => 0,   :null => false
    t.integer  "count_back_stock_in",                                  :default => 0
    t.integer  "count_back_stock_out",                                 :default => 0
    t.integer  "count_front_stock_in",                                 :default => 0
    t.integer  "count_front_stock_out",                                :default => 0
    t.integer  "good_source",                                          :default => 0
    t.string   "pinyin_abbr"
    t.integer  "sale_count",                                           :default => 0,   :null => false
    t.string   "name_pinyin",                                          :default => "",  :null => false
  end

  create_table "member_card_granters", :force => true do |t|
    t.integer  "member_card_id", :null => false
    t.integer  "granter_id",     :null => false
    t.integer  "catena_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "member_id",      :null => false
  end

  create_table "member_cards", :force => true do |t|
    t.integer  "member_id",                                                       :null => false
    t.integer  "card_id",                                                         :null => false
    t.string   "card_serial_num",                                                 :null => false
    t.decimal  "left_fee",        :precision => 10, :scale => 2, :default => 0.0
    t.integer  "left_times",                                     :default => 0
    t.datetime "expire_date",                                                     :null => false
    t.text     "description"
    t.integer  "user_id",                                                         :null => false
    t.string   "password",                                                        :null => false
    t.integer  "catena_id",                                      :default => 0,   :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "status",                                         :default => 0
  end

  create_table "members", :force => true do |t|
    t.string   "name",                        :null => false
    t.string   "name_pinyin",                 :null => false
    t.string   "nickname"
    t.integer  "gender",      :default => 0,  :null => false
    t.datetime "birthday"
    t.string   "telephone"
    t.string   "mobile",                      :null => false
    t.string   "email"
    t.string   "address",     :default => ""
    t.string   "job"
    t.integer  "cert_type",                   :null => false
    t.string   "cert_num",                    :null => false
    t.string   "memo"
    t.string   "mentor"
    t.integer  "fax"
    t.text     "description"
    t.integer  "status",      :default => 1,  :null => false
    t.integer  "catena_id",   :default => 0,  :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "is_member",   :default => 1,  :null => false
    t.string   "pinyin_abbr"
  end

  create_table "non_members", :force => true do |t|
    t.string   "name",                         :null => false
    t.string   "name_pinyin",                  :null => false
    t.string   "telephone"
    t.integer  "catena_id",   :default => 0,   :null => false
    t.datetime "created_at"
    t.float    "earnest",     :default => 0.0, :null => false
  end

  create_table "order_items", :force => true do |t|
    t.integer  "order_id",                 :default => 0, :null => false
    t.integer  "item_id",                  :default => 0, :null => false
    t.integer  "item_type",   :limit => 1, :default => 0, :null => false
    t.integer  "quantity",    :limit => 2, :default => 0, :null => false
    t.integer  "price",                    :default => 0, :null => false
    t.datetime "order_time",                              :null => false
    t.integer  "catena_id",                :default => 0, :null => false
    t.integer  "start_hour",  :limit => 1, :default => 0, :null => false
    t.integer  "end_hour",    :limit => 1, :default => 0, :null => false
    t.date     "order_date",                              :null => false
    t.integer  "paid_status",              :default => 0, :null => false
  end

  create_table "orders", :force => true do |t|
    t.integer  "card_id",                                                     :default => 0,  :null => false
    t.integer  "member_id",                                                   :default => 0,  :null => false
    t.integer  "book_record_id",                                              :default => 0,  :null => false
    t.string   "memo",                                                        :default => "", :null => false
    t.datetime "order_time",                                                                  :null => false
    t.string   "member_name",    :limit => 32,                                :default => "", :null => false
    t.integer  "catena_id",                                                   :default => 0,  :null => false
    t.integer  "member_type",                                                 :default => 1,  :null => false
    t.integer  "member_card_id",                                                              :null => false
    t.integer  "parent_id",                                                                   :null => false
    t.integer  "paid_stauts",                                                 :default => 0,  :null => false
    t.decimal  "amount",                       :precision => 10, :scale => 0, :default => 0,  :null => false
  end

  create_table "period_prices", :force => true do |t|
    t.string   "name",                                                        :null => false
    t.integer  "start_time",                                 :default => 7,   :null => false
    t.integer  "end_time",                                   :default => 7,   :null => false
    t.decimal  "price",       :precision => 10, :scale => 2, :default => 0.0, :null => false
    t.integer  "period_type",                                :default => 0,   :null => false
    t.integer  "catena_id",                                  :default => 0,   :null => false
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "period_prices", ["start_time", "end_time", "period_type"], :name => "index_period_prices_on_start_time_and_end_time_and_period_type", :unique => true

  create_table "powers", :force => true do |t|
    t.string   "subject",     :limit => 36, :default => "", :null => false
    t.string   "string",      :limit => 36, :default => "", :null => false
    t.string   "action",      :limit => 36, :default => "", :null => false
    t.string   "description"
    t.integer  "catena_id",                 :default => 1,  :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "recharge_records", :force => true do |t|
    t.integer  "member_id",                                                      :null => false
    t.integer  "member_card_id",                                                 :null => false
    t.decimal  "recharge_fee",   :precision => 10, :scale => 2, :default => 0.0
    t.integer  "recharge_times",                                :default => 0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "sessions", :force => true do |t|
    t.string   "session_id", :null => false
    t.text     "data"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sessions", ["session_id"], :name => "index_sessions_on_session_id"
  add_index "sessions", ["updated_at"], :name => "index_sessions_on_updated_at"

  create_table "user_powers", :force => true do |t|
    t.integer  "user_id",                   :null => false
    t.integer  "power_id",                  :null => false
    t.integer  "catena_id",  :default => 1, :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "user_name",         :default => "", :null => false
    t.string   "login",                             :null => false
    t.string   "crypted_password",                  :null => false
    t.string   "password_salt",                     :null => false
    t.string   "persistence_token",                 :null => false
    t.integer  "login_count",       :default => 0,  :null => false
    t.datetime "last_request_at"
    t.datetime "last_login_at"
    t.datetime "current_login_at"
    t.string   "last_login_ip"
    t.string   "current_login_ip"
    t.integer  "catena_id",         :default => 0,  :null => false
    t.integer  "status",            :default => 1
  end

  add_index "users", ["last_request_at"], :name => "index_users_on_last_request_at"
  add_index "users", ["login"], :name => "index_users_on_login"
  add_index "users", ["persistence_token"], :name => "index_users_on_persistence_token"

  create_table "vacations", :force => true do |t|
    t.datetime "start_date",                :null => false
    t.datetime "end_date",                  :null => false
    t.string   "name",                      :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "status",     :default => 1
  end

end
