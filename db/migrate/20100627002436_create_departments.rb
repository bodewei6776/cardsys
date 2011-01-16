class CreateDepartments < ActiveRecord::Migration
  def self.up
    create_table :departments , :options => ' DEFAULT CHARSET=utf8' do |t|
      t.string :name,:null => false,:default => '',:limit => 50
    end
  end

  def self.down
    drop_table :departments
  end
end
