class RemoveStateFromVacationStartDate < ActiveRecord::Migration
  def up
    remove_column :vacations, :state
  end

  def down
  end
end
