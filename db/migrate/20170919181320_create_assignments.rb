class CreateAssignments < ActiveRecord::Migration[5.1]
  def change
  	create_table :assignments do |t|
      t.string :assignment_type
      t.string :subject
      t.text :description
      t.string :grade
      t.string :difficulty
      t.boolean :timed
      t.float :time
      t.string :total_points
      t.belongs_to :user, foreign_key: true
      
      t.timestamps
    end
  end
end
