class DropCatenaIdFromCommonResouces < ActiveRecord::Migration
  def self.up
    remove_column :common_resources,:catena_id
  end

  def self.down
    add_column :common_resources,:catena_id,:integer
  end
end
