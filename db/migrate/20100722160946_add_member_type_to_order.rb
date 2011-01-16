class AddMemberTypeToOrder < ActiveRecord::Migration
  
  def self.up
    add_column :orders,:member_type,:integer,:null => false,:default =>1
  end

  def self.down
  end
  
end
