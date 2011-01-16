class CreateMemberCardGranters < ActiveRecord::Migration
  def self.up
    create_table :member_card_granters , :options => ' DEFAULT CHARSET=utf8' do |t|
      t.integer :member_card_id, :null => false
      t.integer :granter_id, :null => false
      t.integer :catena_id
      t.timestamps
    end
  end

  def self.down
    drop_table :member_card_granters
  end
end
