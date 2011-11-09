class CreateMemberCards < ActiveRecord::Migration
  def self.up
    create_table :member_cards  do |t|
      t.integer   :member_id
      t.integer   :card_id
      t.string    :card_serial_num#卡号#自动设置
      t.decimal   :left_fee, :default => 0, :precision => 10, :scale => 2#卡内剩余费用
      t.integer   :left_times, :default => 0#卡内剩余次数
      t.datetime  :expire_date
      t.text      :description
      t.integer   :user_id#办卡客服#自动设置
      t.string    :password#自动设置
      t.string    :state
      t.timestamps
    end
  end

  def self.down
    drop_table :member_cards
  end
end
