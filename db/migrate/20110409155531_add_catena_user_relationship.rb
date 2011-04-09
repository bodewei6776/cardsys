class AddCatenaUserRelationship < ActiveRecord::Migration
  def self.up
    create_table :catenas_users,:id => false do |t|
      t.references :user
      t.references :catena
    end
  end

  def self.down
    drop_table :catenas_users
  end
end
