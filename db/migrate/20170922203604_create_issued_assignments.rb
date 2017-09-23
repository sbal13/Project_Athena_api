class CreateIssuedAssignments < ActiveRecord::Migration[5.1]
  def change
    create_table :issued_assignments do |t|
      t.integer :student_id
      t.string :status
      t.belongs_to :assignment, foreign_key: true
      t.float :final_score
      t.datetime :due_date
      t.datetime :assigned_date

      t.timestamps
    end
  end
end
