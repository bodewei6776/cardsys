class AddTelephoneToMember < ActiveRecord::Migration

  def self.up
    add_column :members,:standby_phone,:string,:limit => 16,:default => '',:null => false
    add_column :members,:consume_amount,:decimal,:null => false,:default => 0
    add_column :members,:consume_counter,:integer,:null => false,:default => 0
  end

  def self.down
    drop_column :members,:standby_phone
    drop_column :members,:consume_amount
    drop_column :members,:consume_counter
  end
  
end
