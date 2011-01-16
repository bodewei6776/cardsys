class CreateMemberCards < ActiveRecord::Migration
  def self.up
    create_table :member_cards , :options => ' DEFAULT CHARSET=utf8' do |t|
      t.integer   :member_id, :null => false
      t.integer   :card_id, :null => false
      t.string    :card_serial_num, :null => false#卡号#自动设置
      t.decimal   :left_fee, :default => 0, :precision => 10, :scale => 2#卡内剩余费用
      t.integer   :left_times, :default => 0#卡内剩余次数
      t.datetime  :expire_date, :null => false#
      t.text      :description
      t.integer   :user_id, :null => false#办卡客服#自动设置
      t.string    :password, :null => false#自动设置
      t.integer   :catena_id, :null => false, :default => 0 #
      t.timestamps
    end
  end

  def self.down
    drop_table :member_cards
  end
end
