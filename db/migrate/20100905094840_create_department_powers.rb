class CreateDepartmentPowers < ActiveRecord::Migration
  def self.up
    create_table :department_powers , :options => ' DEFAULT CHARSET=utf8' do |t|
      t.integer :department_id, :power_id, :null => false
      t.integer :catena_id, :null => false, :default => 1
      t.timestamps
    end
  end

  def self.down
    drop_table :department_powers
  end
end
