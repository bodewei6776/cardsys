class AddRechargePersonNameToRechardRecords < ActiveRecord::Migration

  def change
    add_column :recharge_records, :recharge_person_name, :string
  end
end
