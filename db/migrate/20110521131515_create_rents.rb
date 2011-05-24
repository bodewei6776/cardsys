class CreateRents < ActiveRecord::Migration
  def self.up
    create_table :rents, :options => ' DEFAULT CHARSET=utf8' do |t|
      t.integer :locker_id
      t.integer :member_id
      t.integer :card_id
      t.datetime :start_date
      t.datetime :end_date
      t.decimal :total_fee
      t.integer :pay_way
      t.string :remark

      t.timestamps
    end
  end

  def self.down
    drop_table :rents
  end
end
