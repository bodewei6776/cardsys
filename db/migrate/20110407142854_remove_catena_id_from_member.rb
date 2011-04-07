class RemoveCatenaIdFromMember < ActiveRecord::Migration
  def self.up
    remove_column :members,:catena_id
  end

  def self.down
    add_column :members,:catena_id,:integer
  end
end
