class CreatePowers < ActiveRecord::Migration
  def self.up
    create_table :powers , :options => ' DEFAULT CHARSET=utf8' do |t|      
      t.string  :subject, :string, :null => false, :limit => 36, :default => ''
      t.string  :action, :string, :null => false, :limit => 36, :default => ''
      t.string  :description
      t.integer :catena_id, :null => false, :default => 1
      t.timestamps
    end
  end

  def self.down
    drop_table :powers
  end
end
