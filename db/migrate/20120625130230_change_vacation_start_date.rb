class ChangeVacationStartDate < ActiveRecord::Migration
  def up
    change_column :vacations, :start_date, :date
    change_column :vacations, :end_date, :date
  end

  def down
  end
end
