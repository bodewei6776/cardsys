class AddColumnToTables < ActiveRecord::Migration
  def self.up
    add_column :members, :pinyin_abbr, :string
    add_column :goods, :pinyin_abbr, :string
    add_column :departments, :catena_id, :integer, :null => false, :default => 1
    add_column :department_users, :catena_id, :integer, :null => false, :default => 1
  end

  def self.down
    remove_column :members, :pinyin_abbr
    remove_column :goods, :pinyin_abbr
    remove_column :departments, :catena_id
    remove_column :department_users, :catena_id
  end
end
