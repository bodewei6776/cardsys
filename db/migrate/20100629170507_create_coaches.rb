class CreateCoaches < ActiveRecord::Migration
  def self.up
    create_table :coaches  , :options => ' DEFAULT CHARSET=utf8' do |t|
      t.string :name, :null => false, :default => ''
      t.integer :gender, :null => false, :default => 0 # 0:male, 1:female
      t.string :portrait
      t.integer :coach_type, :null => false, :default => 0 #common_resource_detail_id
      t.string :telephone, :null => false
      t.string :email, :null => false
      t.decimal :fee, :null => false, :default => 0, :precision => 10, :scale => 2
      t.integer :cert_type, :null => false
      t.string :cert_num, :null => false#证件号码非空
      t.text :description
      t.integer :status, :null => false, :default => 0
      t.integer :catena_id, :null => false, :default => 0
      t.timestamps
    end
  end

  def self.down
    drop_table :coaches
  end
end
