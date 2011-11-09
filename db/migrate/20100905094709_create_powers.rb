class CreatePowers < ActiveRecord::Migration
  def self.up
    create_table :powers  do |t|      
      t.string  :subject, :string
      t.string  :action, :string
      t.string  :description
      t.timestamps
    end
  end

  def self.down
    drop_table :powers
  end
end
