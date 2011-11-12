class CreateCommonResourceDetails < ActiveRecord::Migration
  def self.up
    create_table :common_resource_details do |t|
      t.string :detail_name
      t.integer :common_resource_id

      t.timestamps
    end
  end

  def self.down
    drop_table :common_resource_details
  end
end
