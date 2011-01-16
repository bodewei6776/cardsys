class CreateCourts < ActiveRecord::Migration
  def self.up
    create_table :courts , :options => ' DEFAULT CHARSET=utf8' do |t|
      t.string     :name, :null => false, :default => ''
      t.string     :contact, :null => false, :default => ''
      t.string     :telephone
      t.integer    :start_time, :null => false#开放时间
      t.integer    :end_time, :null => false
      t.text       :description
      t.integer    :status, :null => false, :default => 1#Court::Status_Free#默认为空闲状态
      t.integer    :catena_id, :null => false, :default => 0
      t.timestamps
    end
  end

  def self.down
    drop_table :courts
  end
end
