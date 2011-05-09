class CreateCategories < ActiveRecord::Migration
  def self.up
    create_table :categories , :options => ' DEFAULT CHARSET=utf8' do |t|
      t.string :name
      t.integer :parent_id
      t.integer :position

      t.timestamps
    end
  end

  def self.down
    drop_table :categories
  end
end
