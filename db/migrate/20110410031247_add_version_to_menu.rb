class AddVersionToMenu < ActiveRecord::Migration
  def self.up
    add_column :powers,:will_show,:boolean
  end

  def self.down
    remove_column :powers,:will_show
  end
end
