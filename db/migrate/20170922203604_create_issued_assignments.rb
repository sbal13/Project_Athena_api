class CreateIssuedAssignments < ActiveRecord::Migration[5.1]
  def change
    create_table :issued_assignments do |t|
      t.integer :student_id
      t.string :status
      t.belongs_to :assignment, foreign_key: true
      t.text :given_answers, array: true, default: []
      t.float :final_score
      t.datetime :due_date
      t.datetime :assigned_date
      t.text :teacher_comments
      t.datetime :finalized_date
      t.float :question_points, array: true, default: []
      t.timestamps
    end
  end
end
