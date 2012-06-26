class AddVacationTypeToVacations < ActiveRecord::Migration
  def change
    add_column :vacations, :vacation_type, :string
  end
end
