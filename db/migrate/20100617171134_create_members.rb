class CreateMembers < ActiveRecord::Migration
  def self.up
    create_table :members , :options => ' DEFAULT CHARSET=utf8' do |t|
      t.string :name, :name_pinyin, :null => false
      t.string :nickname
      t.integer :gender, :null => false, :default => 0 #0: male, 1:female
      t.datetime :birthday
      t.string :telephone
      t.string :mobile, :null => false
      t.string :email
      t.string :address, :default => ''
      t.string :job
      t.integer :cert_type, :null => false
      t.string :cert_num, :null => false#证件号码非空
      t.string :memo
      t.string :mentor
      t.integer :fax
      t.text :description
      t.integer :status, :null => false, :default => 1 #正常
      t.integer :catena_id, :null => false, :default => 0 #
      t.timestamps
    end
  end

  def self.down
    drop_table :members
  end
end
