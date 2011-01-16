class CreateCatenas < ActiveRecord::Migration
  def self.up
    create_table :catenas , :options => ' DEFAULT CHARSET=utf8' do |t|
      t.string :name, :null => false, :default => ''
      t.timestamps
    end
  end

  def self.down
    drop_table :catenas
  end
end
