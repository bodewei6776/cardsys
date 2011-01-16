class CreateBalances < ActiveRecord::Migration
  
  def self.up
    create_table :balances , :options => ' DEFAULT CHARSET=utf8' do |t|
      t.integer   :order_id,:null => false,:default => 0
      t.decimal   :amount,:realy_amount, :null => false, :default => 0, :precision => 10, :scale => 2 
      t.string    :change_note,:null => false,:default => '',:limit => 80
      t.integer   :order_type,:null => false,:default => 1,:limit => 1
      t.integer   :catena_id,:null => false,:default => 0
      t.integer   :balance_way,:null => false,:default => 0,:limit => 1
      t.integer   :member_type,:null => false,:default => 0,:limit => 1
      t.timestamps
    end
  end

  def self.down
    drop_table :balances
  end
  
end
