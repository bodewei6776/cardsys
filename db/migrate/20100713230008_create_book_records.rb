class CreateBookRecords < ActiveRecord::Migration
  
  def self.up
    create_table :book_records , :options => ' DEFAULT CHARSET=utf8' do |t|
      t.integer    :court_id,:null => false,:default => 0
      t.integer    :end_hour,:start_hour,:null => false,:default => 0,:limit => 1
      t.date       :record_date,:null => false
      t.integer    :status,:null => false,:default => 0,:limit => 1
      t.integer    :catena_id,:null => false,:default => 0
    end
  end

  def self.down
    drop_table :book_records
  end
  
end
