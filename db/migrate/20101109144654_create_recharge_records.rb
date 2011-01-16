class CreateRechargeRecords < ActiveRecord::Migration
  def self.up
    create_table :recharge_records , :options => ' DEFAULT CHARSET=utf8' do |t|
      t.integer :member_id, :null => false
      t.integer :member_card_id, :null => false
      t.decimal :recharge_fee, :default => 0, :precision => 10, :scale => 2#充值金额
      t.integer :recharge_times, :default => 0#充值次数
      t.timestamps
    end
  end

  def self.down
    drop_table :recharge_records
  end
end
