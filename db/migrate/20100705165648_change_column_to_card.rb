class ChangeColumnToCard < ActiveRecord::Migration
  def self.up
    remove_column :cards, :expired
    add_column :cards, :expired, :integer, :null => false, :default => 12

#    remove_column :member_cards, :supplement_times
#    remove_column :member_cards, :authorizer_id
#    remove_column :member_cards, :used_date
  end

  def self.down
#    raise  ActiveRecord::IrreversibleMigration
  end
end
