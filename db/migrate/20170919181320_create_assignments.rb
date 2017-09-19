class CreateAssignments < ActiveRecord::Migration[5.1]
  def change
  	create_table :assignments do |t|
      t.string :type
      t.string :subject
      t.boolean :timed
      t.float :time
      t.belongs_to :user, foreign_key: true
      
      t.timestamps
    end
  end
end
