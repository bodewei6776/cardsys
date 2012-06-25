class ChangeMemberBirthday < ActiveRecord::Migration
  def up
    change_column :members, :birthday, :date
  end

  def down
  end
end
