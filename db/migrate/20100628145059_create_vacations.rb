class CreateVacations < ActiveRecord::Migration
  def self.up
    create_table :vacations , :options => ' DEFAULT CHARSET=utf8' do |t|
      t.datetime :start_date, :null => false
      t.datetime :end_date, :null => false
      t.string :name, :null => false
      t.timestamps
    end
  end

  def self.down
    drop_table :vacations
  end
end
