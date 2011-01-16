class CreateCommonResources < ActiveRecord::Migration
  def self.up
    create_table :common_resources , :options => ' DEFAULT CHARSET=utf8' do |t|
      t.string :name, :null => false
      t.text :description
      t.text :detail_str
      t.integer :catena_id, :null => false, :default => 0
      t.timestamps
    end
  end

  def self.down
    drop_table :common_resources
  end
end
