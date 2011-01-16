class CreateUserPowers < ActiveRecord::Migration
  def self.up
    create_table :user_powers , :options => ' DEFAULT CHARSET=utf8' do |t|
      t.integer :user_id, :power_id, :null => false
      t.integer :catena_id, :null => false, :default => 1
      t.timestamps
    end
  end

  def self.down
    drop_table :user_powers
  end
end
