class CreateNonMembers < ActiveRecord::Migration
  
  def self.up
    create_table :non_members , :options => ' DEFAULT CHARSET=utf8' do |t|
      t.string     :name, :name_pinyin, :null => false
      t.string     :telephone
      t.integer    :catena_id, :null => false, :default => 0 #
      t.datetime   :created_at
      t.float      :earnest,:null => false,:default => 0
    end
  end

  def self.down
    drop_table :non_members
  end
  
end
