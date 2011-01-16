class CreateDepartmentUsers < ActiveRecord::Migration
  def self.up
    create_table :department_users , :options => ' DEFAULT CHARSET=utf8' do |t|
      t.integer :user_id,:null => false
      t.integer :department_id,:null => false
    end
  end

  def self.down
    drop_table :department_users
  end
end
