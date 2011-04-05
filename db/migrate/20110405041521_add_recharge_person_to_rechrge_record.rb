class AddRechargePersonToRechrgeRecord < ActiveRecord::Migration
  def self.up
    add_column :recharge_records,:recharge_person,:integer
  end

  def self.down
    remove_column :recharge_records,:recharge_person
  end
end
