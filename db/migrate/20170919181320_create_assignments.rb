class CreateAssignments < ActiveRecord::Migration[5.1]
  def change
  	create_table :assignments do |t|
      t.string :title
      t.string :assignment_type
      t.string :subject
      t.text :description
      t.string :grade
      t.string :difficulty
      t.boolean :timed
      t.float :time
      t.string :total_points
      t.integer :teacher_id
      t.boolean :protected
      t.integer :creator_id
      t.timestamps
    end
  end
end
