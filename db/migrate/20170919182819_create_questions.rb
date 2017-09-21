class CreateQuestions < ActiveRecord::Migration[5.1]
  def change
    create_table :questions do |t|
      t.string :answer
      t.string :choices, array: true, default: []
      t.integer :point_value
      t.string :question
      t.belongs_to :assignment, foreign_key: true
    end
  end
end
