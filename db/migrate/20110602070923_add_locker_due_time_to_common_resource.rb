class AddLockerDueTimeToCommonResource < ActiveRecord::Migration
  def self.up
    CommonResource.create(:name => "locker_due_time",:description => "储物柜到期提醒时间（天 ）",:detail_str => "7")
  end

  def self.down
    CommonResource.find_by_name("locker_due_time").try(:delete)
  end
end
