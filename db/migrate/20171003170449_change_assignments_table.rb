class ChangeAssignmentsTable < ActiveRecord::Migration[5.1]
  def change
  	add_column :assignments, :historical, :boolean, default: false
  end
end
