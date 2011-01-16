class CreateCommonResourceDetails < ActiveRecord::Migration
  def self.up
    create_table :common_resource_details , :options => ' DEFAULT CHARSET=utf8' do |t|
      t.integer :common_resource_id, :null => false
      t.string :detail_name, :null => false, :default => ''
      t.integer :status, :null => false, :default => 0
      t.integer :catena_id, :null => false, :default => 0
      t.timestamps
    end
  end

  def self.down
    drop_table :common_resource_details
  end
end
