class AddCourtTypeToCourts < ActiveRecord::Migration
  def self.up
    add_column :courts, :court_type, :string
  end

  def self.down
    remove_column :courts, :court_type
  end
end
