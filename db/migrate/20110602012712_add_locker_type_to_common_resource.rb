class AddLockerTypeToCommonResource < ActiveRecord::Migration
  def self.up
    CommonResource.create(:name => "locker_type")
  end

  def self.down
    CommonResource.find_by_name("locker_type").try(:delete)
  end
end
