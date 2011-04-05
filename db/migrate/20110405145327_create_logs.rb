class CreateLogs < ActiveRecord::Migration
  def self.up
    create_table :logs do |t|
      t.string :user_name
      t.integer :user_id
      t.string :desc
      t.string :log_type

      t.timestamps
    end
  end

  def self.down
    drop_table :logs
  end
end
